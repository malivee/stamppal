//
//  AuthenticationManager.swift
//  stamppal
//
//  Manajer autentikasi CloudKit Silent Authentication & Pengelolaan Akun Pengguna.
//  Struktur data akun:
//  - Nama Tampilan (Display Name, boleh spasi)
//  - User ID / Username (Ketat, tanpa spasi, unik)
//  Tanpa Sign in with Apple standar & tanpa batasan umur.
//

import Foundation
import SwiftUI
import Combine
import CloudKit

final class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    
    // MARK: - Published State
    @Published var isCloudKitConnected: Bool = false
    @Published var userRecordID: String = ""
    @Published var username: String = ""              // User ID (unik, tanpa spasi)
    @Published var displayName: String = ""           // Nama Tampilan (boleh spasi)
    @Published var userEmail: String = ""
    @Published var birthDate: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @Published var activeGroupCode: String? = nil
    
    @Published var needsProfileRegistration: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // Lazy container accessor
    private var container: CKContainer {
        CKContainer.default()
    }
    
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    // Computed age (jika dibutuhkan)
    var userAge: Int {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year], from: birthDate, to: Date())
        return max(0, comps.year ?? 0)
    }
    
    // Display helper
    var userFullName: String {
        if !displayName.isEmpty { return displayName }
        if !username.isEmpty { return username }
        return "Pengguna StampPal"
    }
    
    private init() {
        loadFromLocalStorage()
        Task {
            await performSilentAuthentication()
        }
    }
    
    // MARK: - Local Storage Cache
    private func loadFromLocalStorage() {
        self.username = UserDefaults.standard.string(forKey: "app_username") ?? ""
        self.displayName = UserDefaults.standard.string(forKey: "app_display_name") ?? ""
        self.userEmail = UserDefaults.standard.string(forKey: "app_user_email") ?? ""
        self.userRecordID = UserDefaults.standard.string(forKey: "app_user_record_id") ?? ""
        self.activeGroupCode = UserDefaults.standard.string(forKey: "app_active_group_code")
        
        if let savedBirth = UserDefaults.standard.object(forKey: "app_birth_date") as? Date {
            self.birthDate = savedBirth
        }
        
        // Tandai perlu registrasi profil jika username masih kosong
        if self.username.isEmpty {
            self.needsProfileRegistration = true
        }
    }
    
    func saveToLocalStorage() {
        UserDefaults.standard.set(username, forKey: "app_username")
        UserDefaults.standard.set(displayName, forKey: "app_display_name")
        UserDefaults.standard.set(userEmail, forKey: "app_user_email")
        UserDefaults.standard.set(userRecordID, forKey: "app_user_record_id")
        UserDefaults.standard.set(birthDate, forKey: "app_birth_date")
        UserDefaults.standard.set(activeGroupCode, forKey: "app_active_group_code")
    }
    
    // MARK: - Validasi User ID Ketat (Tanpa Spasi)
    static func isValidUsername(_ input: String) -> Bool {
        guard !input.contains(" ") else { return false }
        let predicate = NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z0-9_]{3,20}$")
        return predicate.evaluate(with: input)
    }
    
    static func sanitizeUsername(_ input: String) -> String {
        return input.replacingOccurrences(of: " ", with: "").lowercased()
    }
    
    // MARK: - Pengecekan Duplikasi User ID di CloudKit
    func checkUsernameAvailable(_ candidate: String) async -> Bool {
        let clean = Self.sanitizeUsername(candidate)
        guard Self.isValidUsername(clean) else { return false }
        
        do {
            let predicate = NSPredicate(format: "username == %@", clean)
            let query = CKQuery(recordType: "UserProfile", predicate: predicate)
            let result = try await publicDatabase.records(matching: query)
            
            for (_, matchResult) in result.matchResults {
                if let record = try? matchResult.get() {
                    let owner = record["userRecordName"] as? String ?? ""
                    if owner != self.userRecordID && !self.userRecordID.isEmpty {
                        return false
                    }
                }
            }
            return true
        } catch {
            print("ℹ️ Cek duplikasi User ID: \(error.localizedDescription)")
            return true
        }
    }
    
    // MARK: - Registrasi Akun (Nama & User ID Saja)
    func registerUserProfile(username: String, displayName: String) async throws {
        let cleanUsername = Self.sanitizeUsername(username)
        guard Self.isValidUsername(cleanUsername) else {
            throw NSError(domain: "StampPal", code: 400, userInfo: [NSLocalizedDescriptionKey: "User ID tidak valid. Gunakan 3-20 karakter tanpa spasi."])
        }
        
        let isAvailable = await checkUsernameAvailable(cleanUsername)
        guard isAvailable else {
            throw NSError(domain: "StampPal", code: 409, userInfo: [NSLocalizedDescriptionKey: "User ID '@\(cleanUsername)' sudah dipakai oleh orang lain."])
        }
        
        do {
            let recordID = CKRecord.ID(recordName: "user_\(userRecordID.isEmpty ? UUID().uuidString : userRecordID)")
            let record = CKRecord(recordType: "UserProfile", recordID: recordID)
            
            record["userRecordName"] = (userRecordID.isEmpty ? recordID.recordName : userRecordID) as CKRecordValue
            record["username"] = cleanUsername as CKRecordValue
            record["displayName"] = (displayName.isEmpty ? cleanUsername : displayName) as CKRecordValue
            if let group = activeGroupCode {
                record["activeGroupCode"] = group as CKRecordValue
            }
            
            _ = try await publicDatabase.save(record)
        } catch {
            print("ℹ️ CloudKit save profile info: \(error.localizedDescription)")
        }
        
        await MainActor.run {
            self.username = cleanUsername
            self.displayName = displayName.isEmpty ? cleanUsername : displayName
            self.needsProfileRegistration = false
            self.saveToLocalStorage()
            print("✅ [StampPal] Akun baru berhasil dibuat: @\(cleanUsername) (\(self.displayName))")
        }
    }
    
    // Backward compatibility overload
    func registerUserProfile(username: String, displayName: String, birthDate: Date) async throws {
        try await registerUserProfile(username: username, displayName: displayName)
    }
    
    // MARK: - CloudKit Silent Authentication
    func performSilentAuthentication() async {
        await MainActor.run { self.isLoading = true }
        
        do {
            let status = try await container.accountStatus()
            guard status == .available else {
                print("ℹ️ iCloud status: \(status.rawValue)")
                await MainActor.run {
                    self.isCloudKitConnected = false
                    self.isLoading = false
                    if self.username.isEmpty {
                        self.needsProfileRegistration = true
                    }
                }
                return
            }
            
            let recordID = try await container.userRecordID()
            let recordName = recordID.recordName
            
            await MainActor.run {
                self.userRecordID = recordName
                self.isCloudKitConnected = true
            }
            
            // Cek apakah profil sudah tersimpan di database CloudKit
            let existingProfile = try await fetchUserProfileFromCloudKit(userRecordName: recordName)
            
            await MainActor.run {
                self.isLoading = false
                if let profile = existingProfile {
                    self.username = profile.username
                    self.displayName = profile.displayName
                    self.birthDate = profile.birthDate
                    self.activeGroupCode = profile.activeGroupCode
                    self.needsProfileRegistration = false
                    self.saveToLocalStorage()
                    print("✅ [CloudKit] Profil ditemukan: @\(profile.username) (\(profile.displayName))")
                } else {
                    if self.username.isEmpty {
                        self.needsProfileRegistration = true
                    }
                }
            }
            
        } catch {
            print("ℹ️ CloudKit silent auth info: \(error.localizedDescription)")
            await MainActor.run {
                self.isLoading = false
                if self.username.isEmpty {
                    self.needsProfileRegistration = true
                }
            }
        }
    }
    
    private func fetchUserProfileFromCloudKit(userRecordName: String) async throws -> UserProfile? {
        let predicate = NSPredicate(format: "userRecordName == %@", userRecordName)
        let query = CKQuery(recordType: "UserProfile", predicate: predicate)
        
        let result = try await publicDatabase.records(matching: query)
        for (_, matchResult) in result.matchResults {
            if let record = try? matchResult.get() {
                guard let uname = record["username"] as? String,
                      let dname = record["displayName"] as? String else {
                    continue
                }
                let bdate = (record["birthDate"] as? Date) ?? self.birthDate
                let groupCode = record["activeGroupCode"] as? String
                return UserProfile(
                    userRecordName: userRecordName,
                    username: uname,
                    displayName: dname,
                    birthDate: bdate,
                    activeGroupCode: groupCode
                )
            }
        }
        return nil
    }
    
    // MARK: - Update Active Group
    func updateActiveGroup(code: String?) {
        self.activeGroupCode = code
        saveToLocalStorage()
        
        guard !userRecordID.isEmpty, let code = code else { return }
        Task {
            do {
                let predicate = NSPredicate(format: "userRecordName == %@", self.userRecordID)
                let query = CKQuery(recordType: "UserProfile", predicate: predicate)
                let result = try await self.publicDatabase.records(matching: query)
                for (_, matchResult) in result.matchResults {
                    if let record = try? matchResult.get() {
                        record["activeGroupCode"] = code as CKRecordValue
                        _ = try await self.publicDatabase.save(record)
                    }
                }
            } catch {
                print("ℹ️ Update group in profile error: \(error.localizedDescription)")
            }
        }
    }
}
