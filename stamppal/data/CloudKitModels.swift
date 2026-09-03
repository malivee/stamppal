//
//  CloudKitModels.swift
//  stamppal
//
//  Model data untuk sinkronisasi profil pengguna dan sistem grup berbasis kode via CloudKit.
//

import Foundation
import CloudKit

// MARK: - User Profile Model
struct UserProfile: Identifiable {
    var id: String { userRecordName }
    let userRecordName: String
    var username: String          // Strict, unik, tanpa spasi
    var displayName: String       // Boleh spasi (nama asli)
    var birthDate: Date
    var activeGroupCode: String?
    
    // Perhitungan umur dinamis
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        return max(0, ageComponents.year ?? 0)
    }
}

// MARK: - Postcard Group Model
struct PostcardGroup: Identifiable {
    var id: String { code }
    let code: String              // Kode unik 6 digit alfanumerik (misal: "STAMP8")
    var name: String              // Nama grup (misal: "Keluarga Bahagia")
    var creatorRecordName: String
    var members: [String]         // Array of userRecordNames atau usernames
    var createdAt: Date
}
