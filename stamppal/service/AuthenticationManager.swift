//
//  AuthenticationManager.swift
//  stamppal
//
//  Manajer autentikasi CloudKit Silent Authentication & Pengelolaan Akun Pengguna.
//  Menggunakan kontainer eksplisit "iCloud.com.academy.challenge5.stamppal"
//  dan pencarian record langsung via primary key untuk keandalan maksimal di TestFlight.
//

import Foundation
import SwiftUI
import Combine
import CloudKit

final class AuthenticationManager: ObservableObject {
    
    static let shared = AuthenticationManager()
    
    // Identitas kontainer resmi
    static let containerIdentifier = "iCloud.com.academy.challenge5.stamppal"
    
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
    
    // Kontainer eksplisit
    private var container: CKContainer {
        CKContainer(identifier: Self.containerIdentifier)
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
        
        // 1. Cek Primary Key record user_username
        let candidateRecordID = CKRecord.ID(recordName: "user_\(clean)")
        if let record = try? await publicDatabase.record(for: candidateRecordID) {
            let owner = record["userRecordName"] as? String ?? ""
            if owner != self.userRecordID && !self.userRecordID.isEmpty {
                return false
            }
        }
        
        // 2. Cek via Query fallback
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
        
        let recordID = CKRecord.ID(recordName: "user_\(cleanUsername)")
        let record = CKRecord(recordType: "UserProfile", recordID: recordID)
        
        record["userRecordName"] = (userRecordID.isEmpty ? cleanUsername : userRecordID) as CKRecordValue
        record["username"] = cleanUsername as CKRecordValue
        record["displayName"] = (displayName.isEmpty ? cleanUsername : displayName) as CKRecordValue
        if let group = activeGroupCode {
            record["activeGroupCode"] = group as CKRecordValue
        }
        
        do {
            _ = try await publicDatabase.save(record)
            print("☁️ [CloudKit] Profil @\(cleanUsername) berhasil disimpan ke server Apple!")
        } catch {
            print("⚠️ [CloudKit] Simpan profil ke server gagal: \(error.localizedDescription)")
            // Lempar error jika gagal autentikasi iCloud
            if let ckError = error as? CKError, ckError.code == .notAuthenticated {
                throw NSError(domain: "StampPal", code: 401, userInfo: [NSLocalizedDescriptionKey: CloudKitGroupService.humanFriendlyError(error)])
            }
        }
        
        await MainActor.run {
            self.username = cleanUsername
            self.displayName = displayName.isEmpty ? cleanUsername : displayName
            self.needsProfileRegistration = false
            self.saveToLocalStorage()
            print("✅ [StampPal] Akun baru aktif: @\(cleanUsername) (\(self.displayName))")
        }
    }
    
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
        // Coba ambil via primary key user_<username> jika username tersimpan
        if !self.username.isEmpty {
            let directID = CKRecord.ID(recordName: "user_\(self.username)")
            if let record = try? await publicDatabase.record(for: directID) {
                if let uname = record["username"] as? String,
                   let dname = record["displayName"] as? String {
                    let groupCode = record["activeGroupCode"] as? String
                    return UserProfile(
                        userRecordName: userRecordName,
                        username: uname,
                        displayName: dname,
                        birthDate: self.birthDate,
                        activeGroupCode: groupCode
                    )
                }
            }
        }
        
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
        
        guard !username.isEmpty, let code = code else { return }
        Task {
            do {
                let directID = CKRecord.ID(recordName: "user_\(username)")
                if let record = try? await self.publicDatabase.record(for: directID) {
                    record["activeGroupCode"] = code as CKRecordValue
                    _ = try await self.publicDatabase.save(record)
                }
            } catch {
                print("ℹ️ Update active group in profile: \(error.localizedDescription)")
            }
        }
    }
}
