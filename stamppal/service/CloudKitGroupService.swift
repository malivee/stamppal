//
//  CloudKitGroupService.swift
//  stamppal
//
//  Layanan CloudKit untuk membuat grup dengan ID manual (seperti ID Telegram),
//  bergabung ke grup menggunakan ID manual tersebut, dan saling berkirim kartu pos
//  ke seluruh anggota grup (broadcast) via CloudKit public database.
//

import Foundation
import CloudKit
import SwiftUI

final class CloudKitGroupService {
    
    static let shared = CloudKitGroupService()
    
    private var container: CKContainer {
        CKContainer.default()
    }
    
    private var publicDatabase: CKDatabase {
        container.publicCloudDatabase
    }
    
    private init() {}
    
    // MARK: - Create Group with Manual ID (Telegram Style)
    /// Membuat grup dengan ID yang ditentukan manual oleh pengguna (misal: 'keluarga_asik')
    func createGroup(id: String, name: String) async throws -> PostcardGroup {
        let authManager = AuthenticationManager.shared
        let cleanID = id.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "")
        
        guard cleanID.count >= 3 else {
            throw NSError(domain: "StampPal", code: 400, userInfo: [NSLocalizedDescriptionKey: "ID grup minimal 3 karakter tanpa spasi."])
        }
        
        let myIdentifier = !authManager.username.isEmpty ? authManager.username : (!authManager.displayName.isEmpty ? authManager.displayName : "Pengguna")
        let groupName = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? cleanID : name
        let now = Date()
        
        do {
            // Cek apakah ID grup sudah ada di database CloudKit
            let predicate = NSPredicate(format: "code == %@", cleanID)
            let query = CKQuery(recordType: "PostcardGroup", predicate: predicate)
            let existing = try? await publicDatabase.records(matching: query)
            
            if let count = existing?.matchResults.count, count > 0 {
                throw NSError(domain: "StampPal", code: 409, userInfo: [NSLocalizedDescriptionKey: "ID '@\(cleanID)' sudah dipakai oleh lingkaran lain. Silakan pilih ID yang berbeda."])
            }
            
            let recordID = CKRecord.ID(recordName: "group_\(cleanID)")
            let record = CKRecord(recordType: "PostcardGroup", recordID: recordID)
            
            record["code"] = cleanID as CKRecordValue
            record["name"] = groupName as CKRecordValue
            record["creatorRecordName"] = authManager.userRecordID as CKRecordValue
            record["members"] = [myIdentifier] as CKRecordValue
            record["createdAt"] = now as CKRecordValue
            
            _ = try await publicDatabase.save(record)
        } catch let err as NSError where err.code == 409 {
            throw err
        } catch {
            print("ℹ️ CloudKit create group remote save info: \(error.localizedDescription)")
            UserDefaults.standard.set(groupName, forKey: "local_group_name_\(cleanID)")
        }
        
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
        
        print("✅ [Grup] Berhasil dibuat dengan ID manual: @\(cleanID)")
        return newGroup
    }
    
    // Backward compatibility overload
    func createGroup(name: String) async throws -> PostcardGroup {
        let fallbackID = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "_")
        return try await createGroup(id: fallbackID.isEmpty ? "circle_\(Int.random(in: 100...999))" : fallbackID, name: name)
    }
    
    // MARK: - Join Group with Manual ID
    /// Bergabung ke grup menggunakan ID manual yang dibuat pemilik grup (seperti join ID Telegram)
    func joinGroup(code: String) async throws -> PostcardGroup {
        let cleanID = code.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().replacingOccurrences(of: " ", with: "")
        guard !cleanID.isEmpty else {
            throw NSError(domain: "StampPal", code: 400, userInfo: [NSLocalizedDescriptionKey: "Masukkan ID grup yang ingin kamu ikuti."])
        }
        
        let authManager = AuthenticationManager.shared
        let myIdentifier = !authManager.username.isEmpty ? authManager.username : (!authManager.displayName.isEmpty ? authManager.displayName : "Pengguna")
        
        do {
            let predicate = NSPredicate(format: "code == %@", cleanID)
            let query = CKQuery(recordType: "PostcardGroup", predicate: predicate)
            
            let results = try await publicDatabase.records(matching: query)
            guard let firstMatch = results.matchResults.first else {
                // Cek fallback lokal jika sedang offline
                if let localName = UserDefaults.standard.string(forKey: "local_group_name_\(cleanID)") {
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
                }
                throw NSError(domain: "StampPal", code: 404, userInfo: [NSLocalizedDescriptionKey: "Grup dengan ID '@\(cleanID)' tidak ditemukan. Pastikan ID sudah benar."])
            }
            
            let record = try firstMatch.1.get()
            let name = record["name"] as? String ?? cleanID
            let creator = record["creatorRecordName"] as? String ?? ""
            var members = record["members"] as? [String] ?? []
            let createdAt = record["createdAt"] as? Date ?? Date()
            
            if !members.contains(myIdentifier) {
                members.append(myIdentifier)
                record["members"] = members as CKRecordValue
                _ = try await publicDatabase.save(record)
                print("✅ [CloudKit] Pengguna \(myIdentifier) bergabung ke grup @\(cleanID)")
            }
            
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
        } catch let err as NSError where err.code == 404 {
            throw err
        } catch {
            if let localName = UserDefaults.standard.string(forKey: "local_group_name_\(cleanID)") {
                let group = PostcardGroup(
                    code: cleanID,
                    name: localName,
                    creatorRecordName: "LocalCreator",
                    members: [myIdentifier],
                    createdAt: Date()
                )
                await MainActor.run {
                    authManager.updateActiveGroup(code: cleanID)
                }
                return group
            }
            throw error
        }
    }
    
    // MARK: - Send Postcard to Group (Broadcast)
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
        
        let recordID = CKRecord.ID(recordName: "postcard_\(postcard.id.uuidString)")
        let record = CKRecord(recordType: "GroupPostcard", recordID: recordID)
        
        record["postcardID"] = postcard.id.uuidString as CKRecordValue
        record["groupCode"] = groupCode as CKRecordValue
        record["sender"] = (postcard.sender.isEmpty ? authManager.userFullName : postcard.sender) as CKRecordValue
        record["senderUsername"] = authManager.username as CKRecordValue
        record["recipient"] = (postcard.recipient ?? "Semua Anggota") as CKRecordValue
        record["date"] = postcard.date as CKRecordValue
        record["message"] = postcard.message as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        
        if let data = imageData ?? postcard.imageData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(postcard.id.uuidString)_photo.jpg")
            try? data.write(to: tempURL)
            record["photoAsset"] = CKAsset(fileURL: tempURL)
        }
        
        if let sData = stampData ?? postcard.stampData {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(postcard.id.uuidString)_stamp.png")
            try? sData.write(to: tempURL)
            record["stampAsset"] = CKAsset(fileURL: tempURL)
        }
        
        _ = try await publicDatabase.save(record)
        print("✅ [CloudKit] Postcard berhasil dibroadcast ke grup @\(groupCode)")
    }
    
    // MARK: - Fetch Group Postcards
    func fetchGroupPostcards(groupCode: String) async throws -> [Postcard] {
        guard !groupCode.isEmpty else { return [] }
        
        let predicate = NSPredicate(format: "groupCode == %@", groupCode)
        let query = CKQuery(recordType: "GroupPostcard", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let result = try await publicDatabase.records(matching: query)
        var cards: [Postcard] = []
        
        for (_, matchResult) in result.matchResults {
            guard let record = try? matchResult.get() else { continue }
            
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
        
        return cards
    }
}
