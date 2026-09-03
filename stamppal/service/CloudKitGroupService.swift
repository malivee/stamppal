//
//  CloudKitGroupService.swift
//  stamppal
//
//  Layanan CloudKit Berstandar Industri untuk Pengiriman Online Antar-Pengguna Jarak Jauh.
//  Fitur:
//  1. Kontainer eksplisit: "iCloud.com.academy.challenge5.stamppal"
//  2. Primary Key Direct Record ID ("group_<id>") - 100% BEBAS DARI KEBUTUHAN INDEX DASHBOARD
//  3. Tanpa inisialisasi empty array '[]' agar CloudKit tidak error invalid argument
//  4. Dukungan broadcast kartu pos jarak jauh antar akun iCloud yang berbeda
//

import Foundation
import CloudKit
import SwiftUI

final class CloudKitGroupService {
    
    static let shared = CloudKitGroupService()
    
    // Identitas kontainer resmi
    static let containerIdentifier = "iCloud.com.academy.challenge5.stamppal"
    
    private var container: CKContainer {
        CKContainer(identifier: Self.containerIdentifier)
    }
    
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    private init() {}
    
    // MARK: - Helper Error CloudKit
    static func humanFriendlyError(_ error: Error) -> String {
        if let ckError = error as? CKError {
            switch ckError.code {
            case .notAuthenticated:
                return "Akun iCloud belum aktif di iPhone ini. Buka Pengaturan iPhone > masuk ke Akun Apple / iCloud dan aktifkan iCloud Drive."
            case .networkUnavailable, .networkFailure:
                return "Koneksi internet terputus. Pastikan iPhone terhubung ke internet."
            case .quotaExceeded:
                return "Penyimpanan iCloud penuh."
            case .serviceUnavailable, .requestRateLimited:
                return "Server iCloud sedang sibuk, silakan coba beberapa saat lagi."
            case .unknownItem:
                return "Lingkaran grup tidak ditemukan di CloudKit. Pastikan ID sudah benar."
            case .serverRecordChanged:
                return "ID grup ini sudah dipakai oleh pengguna lain. Silakan pilih ID yang berbeda."
            default:
                return ckError.localizedDescription
            }
        }
        return error.localizedDescription
    }
    
    // MARK: - Create Group with Manual ID (Telegram Style)
    func createGroup(id: String, name: String) async throws -> PostcardGroup {
        let authManager = AuthenticationManager.shared
        let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "")
        
        guard cleanID.count >= 3 else {
            throw NSError(domain: "StampPal", code: 400, userInfo: [NSLocalizedDescriptionKey: "ID grup minimal 3 karakter tanpa spasi."])
        }
        
        let myIdentifier = !authManager.username.isEmpty ? authManager.username : (!authManager.displayName.isEmpty ? authManager.displayName : "Pengguna")
        let groupName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? cleanID : name
        let now = Date()
        let recordID = CKRecord.ID(recordName: "group_\(cleanID)")
        
        // 1. Cek ketersediaan ID (Primary Key Lookup - 0 Index Required)
        do {
            _ = try await publicDatabase.record(for: recordID)
            // Jika record ditemukan, berarti ID sudah dipakai
            throw NSError(domain: "StampPal", code: 409, userInfo: [NSLocalizedDescriptionKey: "ID '@\(cleanID)' sudah dipakai oleh lingkaran lain. Silakan gunakan ID yang berbeda."])
        } catch let err as NSError where err.code == 409 {
            throw err
        } catch let ckError as CKError where ckError.code == .unknownItem {
            // ID bebas dan siap dipakai
        } catch {
            // Lanjut proses
        }
        
        // 2. Buat Record Baru
        let record = CKRecord(recordType: "PostcardGroup", recordID: recordID)
        record["code"] = cleanID as CKRecordValue
        record["name"] = groupName as CKRecordValue
        record["creatorRecordName"] = (authManager.userRecordID.isEmpty ? myIdentifier : authManager.userRecordID) as CKRecordValue
        record["members"] = [myIdentifier] as CKRecordValue
        record["createdAt"] = now as CKRecordValue
        // PENTING: Jangan assign 'postcardIDs = []' karena CloudKit akan error "cannot determine type for empty list"
        
        // 3. Simpan ke CloudKit Public Database
        do {
            _ = try await publicDatabase.save(record)
            print("☁️ [CloudKit] Grup '@\(cleanID)' berhasil disimpan ke server Apple!")
        } catch let ckError as CKError where ckError.code == .serverRecordChanged {
            throw NSError(domain: "StampPal", code: 409, userInfo: [NSLocalizedDescriptionKey: "ID '@\(cleanID)' sudah dipakai oleh lingkaran lain. Silakan pilih ID yang berbeda."])
        } catch {
            print("❌ [CloudKit] Gagal menyimpan grup ke server: \(error.localizedDescription)")
            UserDefaults.standard.set(groupName, forKey: "local_group_name_\(cleanID)")
            throw NSError(domain: "StampPal", code: 500, userInfo: [NSLocalizedDescriptionKey: Self.humanFriendlyError(error)])
        }
        
        UserDefaults.standard.set(groupName, forKey: "local_group_name_\(cleanID)")
        
        let newGroup = PostcardGroup(
            code: cleanID,
            name: groupName,
            creatorRecordName: authManager.userRecordID,
            members: [myIdentifier],
            createdAt: now
        )
        
        await MainActor.run {
            authManager.updateActiveGroup(code: cleanID)
        }
        
        return newGroup
    }
    
    // Backward compatibility overload
    func createGroup(name: String) async throws -> PostcardGroup {
        let fallbackID = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "_")
        return try await createGroup(id: fallbackID.isEmpty ? "circle_\(Int.random(in: 100...999))" : fallbackID, name: name)
    }
    
    // MARK: - Join Group with Manual ID
    func joinGroup(code: String) async throws -> PostcardGroup {
        let cleanID = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "")
        guard !cleanID.isEmpty else {
            throw NSError(domain: "StampPal", code: 400, userInfo: [NSLocalizedDescriptionKey: "Masukkan ID grup yang ingin Anda ikuti."])
        }
        
        let authManager = AuthenticationManager.shared
        let myIdentifier = !authManager.username.isEmpty ? authManager.username : (!authManager.displayName.isEmpty ? authManager.displayName : "Pengguna")
        let recordID = CKRecord.ID(recordName: "group_\(cleanID)")
        
        // 1. Ambil Record Langsung via Primary Key (Bebas Index Dashboard)
        let record: CKRecord
        do {
            record = try await publicDatabase.record(for: recordID)
        } catch let ckError as CKError where ckError.code == .unknownItem {
            // Coba fallback query
            let predicate = NSPredicate(format: "code == %@", cleanID)
            let query = CKQuery(recordType: "PostcardGroup", predicate: predicate)
            if let results = try? await publicDatabase.records(matching: query),
               let first = results.matchResults.first,
               let fallbackRecord = try? first.1.get() {
                record = fallbackRecord
            } else if let localName = UserDefaults.standard.string(forKey: "local_group_name_\(cleanID)") {
                let localGroup = PostcardGroup(
                    code: cleanID,
                    name: localName,
                    creatorRecordName: "LocalCreator",
                    members: [myIdentifier],
                    createdAt: Date()
                )
                await MainActor.run {
                    authManager.updateActiveGroup(code: cleanID)
                }
                return localGroup
            } else {
                throw NSError(domain: "StampPal", code: 404, userInfo: [NSLocalizedDescriptionKey: "Lingkaran dengan ID '@\(cleanID)' tidak ditemukan. Pastikan ID sudah benar dan pembuat grup sudah membuatnya."])
            }
        } catch {
            throw NSError(domain: "StampPal", code: 500, userInfo: [NSLocalizedDescriptionKey: Self.humanFriendlyError(error)])
        }
        
        let name = record["name"] as? String ?? cleanID
        let creator = record["creatorRecordName"] as? String ?? ""
        var members = record["members"] as? [String] ?? []
        let createdAt = record["createdAt"] as? Date ?? Date()
        
        // 2. Tambahkan User ke Daftar Anggota di CloudKit
        if !members.contains(myIdentifier) {
            members.append(myIdentifier)
            record["members"] = members as CKRecordValue
            
            do {
                _ = try await publicDatabase.save(record)
                print("☁️ [CloudKit] Anggota '\(myIdentifier)' berhasil bergabung ke grup '@\(cleanID)' di CloudKit!")
            } catch {
                print("⚠️ [CloudKit] Catatan update anggota: \(error.localizedDescription)")
            }
        }
        
        UserDefaults.standard.set(name, forKey: "local_group_name_\(cleanID)")
        
        let group = PostcardGroup(
            code: cleanID,
            name: name,
            creatorRecordName: creator,
            members: members,
            createdAt: createdAt
        )
        
        await MainActor.run {
            authManager.updateActiveGroup(code: cleanID)
        }
        
        return group
    }
    
    // MARK: - Send Postcard to Group (Broadcast Online)
    func sendPostcardToGroup(
        postcard: Postcard,
        imageData: Data?,
        stampData: Data?
    ) async throws {
        let authManager = AuthenticationManager.shared
        guard let groupCode = authManager.activeGroupCode ?? postcard.groupCode, !groupCode.isEmpty else {
            print("ℹ️ Tidak ada groupCode aktif, kartu pos disimpan lokal.")
            return
        }
        
        let postcardRecordName = "postcard_\(postcard.id.uuidString)"
        let postcardRecordID = CKRecord.ID(recordName: postcardRecordName)
        let record = CKRecord(recordType: "GroupPostcard", recordID: postcardRecordID)
        
        record["postcardID"] = postcard.id.uuidString as CKRecordValue
        record["groupCode"] = groupCode as CKRecordValue
        record["sender"] = (postcard.sender.isEmpty ? authManager.userFullName : postcard.sender) as CKRecordValue
        record["senderUsername"] = authManager.username as CKRecordValue
        record["recipient"] = (postcard.recipient ?? "Semua Anggota") as CKRecordValue
        record["date"] = postcard.date as CKRecordValue
        record["message"] = postcard.message as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        // File Foto (CKAsset)
        if let data = imageData ?? postcard.imageData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(postcard.id.uuidString)_photo.jpg")
            try? data.write(to: tempURL)
            record["photoAsset"] = CKAsset(fileURL: tempURL)
        }
        
        // File Prangko (CKAsset)
        if let sData = stampData ?? postcard.stampData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(postcard.id.uuidString)_stamp.png")
            try? sData.write(to: tempURL)
            record["stampAsset"] = CKAsset(fileURL: tempURL)
        }
        
        print("================================")
        print("📤 CLOUDKIT SEND DEBUG")
        print("================================")
        print("Record Type:", record.recordType)
        print("Record ID:", record.recordID.recordName)
        print("groupCode:", record["groupCode"] as? String ?? "NIL")
        print("sender:", record["sender"] as? String ?? "NIL")
        print("recipient:", record["recipient"] as? String ?? "NIL")
        print("================================")
        
        // 1. Simpan Record Kartu Pos ke Public Database
        _ = try await publicDatabase.save(record)
        print("☁️ [CloudKit] Record kartu pos '\(postcardRecordName)' berhasil diunggah!")
        
        // 2. Daftarkan ID kartu pos ke record grup agar dapat difetch via primary key
        let groupRecordID = CKRecord.ID(recordName: "group_\(groupCode)")
        if let groupRecord = try? await publicDatabase.record(for: groupRecordID) {
            var currentIDs = groupRecord["postcardIDs"] as? [String] ?? []
            if !currentIDs.contains(postcardRecordName) {
                currentIDs.append(postcardRecordName)
                groupRecord["postcardIDs"] = currentIDs as CKRecordValue
                _ = try? await publicDatabase.save(groupRecord)
                print("☁️ [CloudKit] ID kartu pos didaftarkan ke grup '@\(groupCode)'!")
            }
        }
    }
    
    // MARK: - Fetch Group Postcards
    func fetchGroupPostcards(groupCode: String) async throws -> [Postcard] {
        guard !groupCode.isEmpty else { return [] }
        
        var fetchedRecords: [CKRecord] = []
        var fetchedRecordNames = Set<String>()
        
        // METODE 1: Ambil via array 'postcardIDs' dari record grup (Primary Key Lookup - 100% BEBAS INDEX)
        let groupRecordID = CKRecord.ID(recordName: "group_\(groupCode)")
        if let groupRecord = try? await publicDatabase.record(for: groupRecordID),
           let ids = groupRecord["postcardIDs"] as? [String], !ids.isEmpty {
            let recordIDs = ids.map { CKRecord.ID(recordName: $0) }
            if let results = try? await publicDatabase.records(for: recordIDs) {
                for (id, result) in results {
                    if let record = try? result.get() {
                        fetchedRecords.append(record)
                        fetchedRecordNames.insert(id.recordName)
                    }
                }
            }
        }
        
        // METODE 2: Backup via Query CloudKit
        let predicate = NSPredicate(format: "groupCode == %@", groupCode)
        let query = CKQuery(recordType: "GroupPostcard", predicate: predicate)
        
        if let result = try? await publicDatabase.records(matching: query) {
            for (id, matchResult) in result.matchResults {
                if !fetchedRecordNames.contains(id.recordName), let record = try? matchResult.get() {
                    fetchedRecords.append(record)
                    fetchedRecordNames.insert(id.recordName)
                }
            }
        }
        
        // Konversi CKRecord ke Model Postcard
        var cards: [Postcard] = []
        for record in fetchedRecords {
            let idString = record["postcardID"] as? String ?? record.recordID.recordName
            let uuid = UUID(uuidString: idString) ?? UUID()
            let sender = record["sender"] as? String ?? "Teman"
            let recipient = record["recipient"] as? String ?? "Semua Anggota"
            let date = record["date"] as? String ?? ""
            let message = record["message"] as? String ?? ""
            let senderUsername = record["senderUsername"] as? String
            
            var photoData: Data? = nil
            if let asset = record["photoAsset"] as? CKAsset, let fileURL = asset.fileURL {
                photoData = try? Data(contentsOf: fileURL)
            }
            
            var stampData: Data? = nil
            if let sAsset = record["stampAsset"] as? CKAsset, let sURL = sAsset.fileURL {
                stampData = try? Data(contentsOf: sURL)
            }
            
            let card = Postcard(
                id: uuid,
                imageName: photoData == nil ? "placeholderImage" : nil,
                imageData: photoData,
                sender: sender,
                recipient: recipient,
                date: date,
                message: message,
                stampData: stampData,
                groupCode: groupCode,
                senderUsername: senderUsername,
                senderDisplayName: sender
            )
            cards.append(card)
        }
        
        print("📥 [CloudKit] Berhasil mengambil \(cards.count) kartu pos untuk grup @\(groupCode)")
        return cards
    }
}
