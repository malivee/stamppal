//
//  NewUserRegistrationSheet.swift
//  stamppal
//
//  Layar Pembuatan Akun StampPal:
//  - Hanya meminta Nama Tampilan dan User ID unik (tanpa batasan umur).
//  - Tampilan UI premium bernuansa pos/kartu pos dengan teks hitam kontras dan validasi real-time.
//

import SwiftUI

struct NewUserRegistrationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    @State private var inputDisplayName: String = ""
    @State private var inputUsername: String = ""
    
    @State private var isCheckingAvailability: Bool = false
    @State private var isUsernameAvailable: Bool? = nil
    @State private var errorMessage: String? = nil
    @State private var isSaving: Bool = false
    
    var onComplete: () -> Void
    
    // Validasi kelengkapan data form
    private var isFormValid: Bool {
        !inputDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        AuthenticationManager.isValidUsername(inputUsername) &&
        !inputUsername.contains(" ") &&
        inputUsername.count >= 3
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradasi lembut khas StampPal
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
                        
                        // MARK: - Header Visual (Prangko & Identitas)
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 86, height: 86)
                                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "envelope.badge.shield.half.filled")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                            }
                            .padding(.top, 16)
                            
                            Text("Buat Akun StampPal")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                            
                            Text("Atur nama tampilan dan ID unikmu untuk mulai bertukar kartu pos bersama teman dan keluarga.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)
                        }
                        
                        // MARK: - Form Card
                        VStack(alignment: .leading, spacing: 20) {
                            
                            // 1. Input Nama Tampilan (Display Name)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("Nama Lengkap / Tampilan")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.30))
                                    
                                    Spacer()
                                    
                                    Text("Boleh spasi")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                }
                                
                                HStack(spacing: 10) {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                        .frame(width: 20)
                                    
                                    TextField("contoh: Silalahi Klery", text: $inputDisplayName)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.black)
                                        .tint(.black)
                                        .autocorrectionDisabled()
                                }
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.25), lineWidth: 1))
                                
                                Text("Nama ini akan tercetak sebagai pengirim di setiap kartu pos yang kamu kirim.")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                            }
                            
                            // 2. Input User ID (Username Ketat: Tanpa Spasi)
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text("User ID (Username)")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.15, green: 0.20, blue: 0.30))
                                    
                                    Spacer()
                                    
                                    if isCheckingAvailability {
                                        ProgressView().scaleEffect(0.7)
                                    } else if let available = isUsernameAvailable {
                                        HStack(spacing: 3) {
                                            Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                                            Text(available ? "Tersedia" : "Sudah dipakai")
                                        }
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(available ? .green : .red)
                                    }
                                }
                                
                                HStack(spacing: 8) {
                                    Text("@")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                    
                                    TextField("contoh: silalahiklery", text: $inputUsername)
                                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                                        .foregroundColor(.black)
                                        .tint(.black)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .onChange(of: inputUsername) { _, newValue in
                                            // Hapus spasi secara instan saat pengguna mengetik
                                            let clean = newValue.replacingOccurrences(of: " ", with: "").lowercased()
                                            if clean != newValue {
                                                inputUsername = clean
                                            }
                                            checkAvailabilityDebounced(clean)
                                        }
                                }
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(inputUsername.contains(" ") ? Color.red : Color.gray.opacity(0.25), lineWidth: 1)
                                )
                                
                                Text("ID unik akunmu (3-20 karakter alfanumerik, tanpa spasi).")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 4)
                            }
                            
                            if let error = errorMessage {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(error)
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal, 4)
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 24)
                        
                        // MARK: - Tombol Simpan & Mulai
                        Button {
                            saveAccountAction()
                        } label: {
                            HStack {
                                if isSaving {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Simpan & Lanjutkan")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                isFormValid
                                ? Color(red: 0.04, green: 0.12, blue: 0.45)
                                : Color.gray.opacity(0.45)
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
                        }
                        .buttonStyle(.plain)
                        .disabled(!isFormValid || isSaving)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Pendaftaran Akun")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !authManager.displayName.isEmpty {
                    inputDisplayName = authManager.displayName
                }
                if !authManager.username.isEmpty {
                    inputUsername = authManager.username
                }
            }
        }
    }
    
    // MARK: - Availability Debounced Check
    private func checkAvailabilityDebounced(_ username: String) {
        guard AuthenticationManager.isValidUsername(username) else {
            isUsernameAvailable = nil
            return
        }
        
        isCheckingAvailability = true
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            let available = await authManager.checkUsernameAvailable(username)
            await MainActor.run {
                if self.inputUsername == username {
                    self.isUsernameAvailable = available
                    self.isCheckingAvailability = false
                }
            }
        }
    }
    
    // MARK: - Action Simpan Akun
    private func saveAccountAction() {
        guard isFormValid else { return }
        
        isSaving = true
        errorMessage = nil
        
        Task {
            do {
                let cleanName = inputDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
                let cleanUname = AuthenticationManager.sanitizeUsername(inputUsername)
                
                try await authManager.registerUserProfile(
                    username: cleanUname,
                    displayName: cleanName
                )
                
                await MainActor.run {
                    self.isSaving = false
                    dismiss()
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSaving = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NewUserRegistrationSheet {}
}
