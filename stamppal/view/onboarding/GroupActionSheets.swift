//
//  GroupActionSheets.swift
//  stamppal
//
//  Sheet interaktif untuk:
//  1. Create Group: Hanya meminta Nama Grup dan ID Grup manual.
//  2. Join Group: Hanya meminta ID Grup untuk langsung terkoneksi.
//  Semua input TextField memiliki teks warna HITAM pekat agar terlihat jelas.
//

import SwiftUI

// MARK: - Create Group Sheet (Nama Grup & ID Grup Saja)
struct CreateGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    @State private var groupName: String = ""
    @State private var groupID: String = ""
    
    @State private var isCreating: Bool = false
    @State private var createdGroup: PostcardGroup? = nil
    @State private var errorMessage: String? = nil
    @State private var isCopied: Bool = false
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.88, green: 0.94, blue: 1.0),
                        Color(red: 0.94, green: 0.97, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        if let group = createdGroup {
                            // MARK: - Tampilan Sukses Dibuat
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.green)
                                
                                Text("Grup Berhasil Dibuat!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                                
                                Text("Bagikan ID ini ke orang terdekat agar mereka bisa langsung bergabung:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                                
                                // Badge ID Telegram Style
                                HStack(spacing: 12) {
                                    Text("@\(group.code)")
                                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                    
                                    Button {
                                        UIPasteboard.general.string = group.code
                                        withAnimation {
                                            isCopied = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            isCopied = false
                                        }
                                    } label: {
                                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color(red: 0.04, green: 0.12, blue: 0.45))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                
                                if isCopied {
                                    Text("ID berhasil disalin ke clipboard!")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.green)
                                }
                                
                                Spacer(minLength: 30)
                                
                                Button {
                                    dismiss()
                                    onComplete()
                                } label: {
                                    Text("Mulai Mengirim Kartu Pos")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0.04, green: 0.12, blue: 0.45))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 40)
                        } else {
                            // MARK: - Form Pembuatan Grup (Nama Grup & ID Grup Saja)
                            VStack(spacing: 20) {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                
                                Text("Buat Lingkaran Baru")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                                
                                Text("Masukkan nama lingkaran dan buat ID unik untuk saling terhubung.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                // 1. Input Nama Grup
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Nama Grup / Lingkaran")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.30))
                                    
                                    ZStack(alignment: .leading) {
                                        if groupName.isEmpty {
                                            Text("contoh: Keluarga Cemara")
                                                .font(.system(size: 15, weight: .regular))
                                                .foregroundColor(Color(red: 0.38, green: 0.44, blue: 0.54))
                                        }
                                        TextField("", text: $groupName)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.black)
                                            .tint(.black)
                                    }
                                    .padding(14)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.35), lineWidth: 1))
                                }
                                .padding(.horizontal, 20)
                                
                                // 2. Input ID Grup (Telegram Style, Tanpa Spasi)
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("ID Grup (Unik)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.30))
                                        
                                        Spacer()
                                        
                                        Text("Tanpa spasi")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack(spacing: 6) {
                                        Text("@")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        ZStack(alignment: .leading) {
                                            if groupID.isEmpty {
                                                Text("contoh: keluarga_Cemara")
                                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                                    .foregroundColor(Color(red: 0.38, green: 0.44, blue: 0.54))
                                            }
                                            TextField("", text: $groupID)
                                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                                .foregroundColor(.black)
                                                .tint(.black)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled(true)
                                                .onChange(of: groupID) { _, newValue in
                                                    groupID = newValue.lowercased().replacingOccurrences(of: " ", with: "")
                                                }
                                        }
                                    }
                                    .padding(14)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.35), lineWidth: 1))
                                }
                                .padding(.horizontal, 20)
                                
                                if let error = errorMessage {
                                    Text(error)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                                
                                Spacer(minLength: 20)
                                
                                Button {
                                    createGroupAction()
                                } label: {
                                    HStack {
                                        if isCreating {
                                            ProgressView().tint(.white)
                                        } else {
                                            Text("Buat Grup Sekarang")
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        isValid
                                        ? Color(red: 0.04, green: 0.12, blue: 0.45)
                                        : Color.gray.opacity(0.5)
                                    )
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .disabled(isCreating || !isValid)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            }
                            .padding(.top, 24)
                        }
                    }
                }
            }
            .navigationTitle("Buat Lingkaran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                }
            }
        }
    }
    
    private var isValid: Bool {
        !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        groupID.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3
    }
    
    private func createGroupAction() {
        let cleanID = groupID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanName = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard cleanID.count >= 3 else {
            errorMessage = "ID grup minimal 3 karakter."
            return
        }
        
        isCreating = true
        errorMessage = nil
        
        Task {
            do {
                let group = try await CloudKitGroupService.shared.createGroup(id: cleanID, name: cleanName)
                await MainActor.run {
                    self.createdGroup = group
                    self.isCreating = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = CloudKitGroupService.humanFriendlyError(error)
                    self.isCreating = false
                }
            }
        }
    }
}

// MARK: - Join Group Sheet (Hanya Memasukkan ID Grup)
struct JoinGroupSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    @State private var inputID: String = ""
    @State private var isJoining: Bool = false
    @State private var joinedGroup: PostcardGroup? = nil
    @State private var errorMessage: String? = nil
    
    var onComplete: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.88, green: 0.94, blue: 1.0),
                        Color(red: 0.94, green: 0.97, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        if let group = joinedGroup {
                            // MARK: - Tampilan Sukses Terkoneksi
                            VStack(spacing: 16) {
                                Image(systemName: "person.crop.circle.badge.checkmark")
                                    .font(.system(size: 64))
                                    .foregroundColor(.green)
                                
                                Text("Terkoneksi ke Grup!")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                                
                                Text("Kamu sekarang sudah terhubung dengan:")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                VStack(spacing: 6) {
                                    Text(group.name)
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                    
                                    Text("@\(group.code) • \(group.members.count) Anggota")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                                .padding(.horizontal, 30)
                                
                                Spacer(minLength: 30)
                                
                                Button {
                                    dismiss()
                                    onComplete()
                                } label: {
                                    Text("Masuk ke StampPal")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color(red: 0.04, green: 0.12, blue: 0.45))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                            .padding(.top, 40)
                        } else {
                            // MARK: - Form Gabung Grup (Hanya ID Grup)
                            VStack(spacing: 20) {
                                Image(systemName: "at.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                
                                Text("Gabung ke Lingkaran")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                                
                                Text("Ketik ID grup yang dibagikan untuk langsung terkoneksi.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                                
                                // Input ID Grup
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("ID Grup")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.30))
                                    
                                    HStack(spacing: 6) {
                                        Text("@")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                        
                                        ZStack(alignment: .leading) {
                                            if inputID.isEmpty {
                                                Text("contoh: sahabat_sejati")
                                                    .font(.system(size: 15, weight: .regular, design: .monospaced))
                                                    .foregroundColor(Color(red: 0.38, green: 0.44, blue: 0.54))
                                            }
                                            TextField("", text: $inputID)
                                                .font(.system(size: 15, weight: .medium, design: .monospaced))
                                                .foregroundColor(.black)
                                                .tint(.black)
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled(true)
                                                .onChange(of: inputID) { _, newValue in
                                                    inputID = newValue.lowercased().replacingOccurrences(of: " ", with: "")
                                                }
                                        }
                                    }
                                    .padding(14)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.35), lineWidth: 1))
                                }
                                .padding(.horizontal, 20)
                                
                                if let error = errorMessage {
                                    Text(error)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.red)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                                
                                Spacer(minLength: 20)
                                
                                Button {
                                    joinGroupAction()
                                } label: {
                                    HStack {
                                        if isJoining {
                                            ProgressView().tint(.white)
                                        } else {
                                            Text("Gabung Sekarang")
                                                .font(.system(size: 16, weight: .bold))
                                        }
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        !inputID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                        ? Color(red: 0.04, green: 0.12, blue: 0.45)
                                        : Color.gray.opacity(0.5)
                                    )
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                                .disabled(isJoining || inputID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .padding(.horizontal, 20)
                                .padding(.bottom, 24)
                            }
                            .padding(.top, 24)
                        }
                    }
                }
            }
            .navigationTitle("Gabung Lingkaran")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Tutup") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                }
            }
        }
    }
    
    private func joinGroupAction() {
        let cleanID = inputID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanID.isEmpty else { return }
        
        isJoining = true
        errorMessage = nil
        
        Task {
            do {
                let group = try await CloudKitGroupService.shared.joinGroup(code: cleanID)
                await MainActor.run {
                    self.joinedGroup = group
                    self.isJoining = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = CloudKitGroupService.humanFriendlyError(error)
                    self.isJoining = false
                }
            }
        }
    }
}
