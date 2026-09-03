//
//  ProfileView.swift
//  stamppal
//
//  Tampilan Profil Pengguna StampPal.
//  Menampilkan:
//  - Display Name (Nama asli / boleh spasi)
//  - @Username (Ketat, unik, tanpa spasi)
//  - Umur / Tanggal Lahir (Dihitung otomatis)
//  - Kode Grup Aktif dengan fitur Salin Kode
//  - Email Pengguna yang otomatis disembunyikan (Auto-hide)
//

import SwiftUI

struct ProfileView: View {

    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var isEmailRevealed: Bool = false
    @State private var isCodeCopied: Bool = false
    @State private var showingCreateGroupSheet: Bool = false
    @State private var showingJoinGroupSheet: Bool = false
    @State private var showingEditProfileSheet: Bool = false
    
    // Auto-hide email logic
    private var displayEmail: String {
        let email = authManager.userEmail.isEmpty ? "icloud.user@icloud.com" : authManager.userEmail
        if isEmailRevealed {
            return email
        } else {
            return maskEmail(email)
        }
    }
    
    private func maskEmail(_ email: String) -> String {
        let parts = email.components(separatedBy: "@")
        guard parts.count == 2, let username = parts.first, let domain = parts.last else {
            return "••••••••••"
        }
        let visibleCount = min(2, username.count)
        let prefix = username.prefix(visibleCount)
        let maskedStars = String(repeating: "•", count: 8)
        return "\(prefix)\(maskedStars)@\(domain)"
    }

    var body: some View {

        ZStack {

            // MARK: - Background

            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.88, blue: 1.00),
                    Color(red: 0.91, green: 0.96, blue: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()


            // MARK: - Content

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: - Title

                    HStack {
                        Text("Profile")
                            .font(
                                .system(
                                    size: UIDevice.isPad ? 54 : 32,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.black)

                        Spacer()
                    }
                    .padding(.horizontal, UIDevice.isPad ? 80 : 24)
                    .padding(.top, UIDevice.isPad ? 55 : 24)

                    Spacer(minLength: UIDevice.isPad ? 35 : 18)

                    // MARK: - Profile Information Card

                    VStack(spacing: UIDevice.isPad ? 14 : 8) {

                        // Profile Icon
                        Image(systemName: "person.fill")
                            .font(
                                .system(
                                    size: UIDevice.isPad ? 52 : 38,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.black)
                            .frame(
                                width: UIDevice.isPad ? 100 : 76,
                                height: UIDevice.isPad ? 100 : 76
                            )
                            .background(
                                Circle()
                                    .fill(
                                        .white.opacity(0.55)
                                    )
                            )
                            .overlay(
                                Circle()
                                    .stroke(
                                        .white.opacity(0.8),
                                        lineWidth: 1
                                    )
                            )

                        // 1. Display Name (Boleh Spasi)
                        Text(authManager.displayName.isEmpty ? (authManager.username.isEmpty ? "Pengguna Baru" : authManager.username) : authManager.displayName)
                            .font(
                                .system(
                                    size: UIDevice.isPad ? 32 : 22,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)

                        // 2. User ID (Strict, Tanpa Spasi)
                        if !authManager.username.isEmpty {
                            Text("@\(authManager.username)")
                                .font(
                                    .system(
                                        size: UIDevice.isPad ? 20 : 14,
                                        weight: .semibold,
                                        design: .monospaced
                                    )
                                )
                                .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                        }

                        // 3. Email (Auto-hidden by default with toggle)
                        HStack(spacing: 6) {
                            Text(displayEmail)
                                .font(
                                    .system(
                                        size: UIDevice.isPad ? 20 : 13,
                                        weight: .regular
                                    )
                                )
                                .foregroundStyle(.gray)
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isEmailRevealed.toggle()
                                }
                            } label: {
                                Image(systemName: isEmailRevealed ? "eye" : "eye.slash")
                                    .font(.system(size: UIDevice.isPad ? 15 : 12))
                                    .foregroundStyle(.gray.opacity(0.75))
                                    .padding(4)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // 4. CloudKit Connection Indicator
                        HStack(spacing: 6) {
                            Image(systemName: authManager.isCloudKitConnected ? "checkmark.icloud.fill" : "icloud.fill")
                                .font(.system(size: UIDevice.isPad ? 14 : 11))
                                .foregroundColor(authManager.isCloudKitConnected ? .green : .gray)
                            
                            Text(authManager.isCloudKitConnected ? "CloudKit Terhubung" : "iCloud Siap")
                                .font(.system(size: UIDevice.isPad ? 14 : 11, weight: .medium))
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .padding(.top, 2)
                    }

                    // MARK: - Active Group Code Banner
                    if let groupCode = authManager.activeGroupCode, !groupCode.isEmpty {
                        VStack(spacing: 8) {
                            Text("KODE GRUP AKTIF")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45).opacity(0.7))
                            
                            HStack(spacing: 12) {
                                Text(groupCode)
                                    .font(.system(size: 24, weight: .black, design: .monospaced))
                                    .foregroundColor(Color(red: 0.04, green: 0.12, blue: 0.45))
                                    .tracking(4)
                                
                                Button {
                                    UIPasteboard.general.string = groupCode
                                    withAnimation {
                                        isCodeCopied = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isCodeCopied = false
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: isCodeCopied ? "checkmark" : "doc.on.doc")
                                        Text(isCodeCopied ? "Tersalin" : "Salin")
                                    }
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color(red: 0.04, green: 0.12, blue: 0.45))
                                    .clipShape(Capsule())
                                }
                            }
                            
                            Text("Bagikan kode ini agar orang lain bisa bergabung dan berkirim kartu pos.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
                        .padding(.horizontal, UIDevice.isPad ? 170 : 24)
                        .padding(.top, 18)
                    }

                    Spacer(minLength: UIDevice.isPad ? 35 : 20)

                    // MARK: - Profile Options

                    VStack(spacing: 0) {

                        ProfileRow(
                            title: "Buat Lingkaran Baru"
                        ) {
                            showingCreateGroupSheet = true
                        }

                        Divider()
                            .padding(.horizontal, UIDevice.isPad ? 24 : 16)

                        ProfileRow(
                            title: "Gabung Lingkaran Lain (Input ID)"
                        ) {
                            showingJoinGroupSheet = true
                        }

                        Divider()
                            .padding(.horizontal, UIDevice.isPad ? 24 : 16)

                        ProfileRow(
                            title: "Edit Profil (Nama & User ID)"
                        ) {
                            showingEditProfileSheet = true
                        }

                        Divider()
                            .padding(.horizontal, UIDevice.isPad ? 24 : 16)

                        ProfileRow(
                            title: "Sinkronkan iCloud"
                        ) {
                            Task {
                                await authManager.performSilentAuthentication()
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(
                            cornerRadius: UIDevice.isPad ? 30 : 20,
                            style: .continuous
                        )
                        .fill(.white)
                    )
                    .padding(.horizontal, UIDevice.isPad ? 170 : 24)

                    Spacer(minLength: UIDevice.isPad ? 80 : 30)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingCreateGroupSheet) {
            CreateGroupSheet {}
        }
        .sheet(isPresented: $showingJoinGroupSheet) {
            JoinGroupSheet {}
        }
        .sheet(isPresented: $showingEditProfileSheet) {
            NewUserRegistrationSheet {
                showingEditProfileSheet = false
            }
        }
    }
}

// MARK: - Profile Row

struct ProfileRow: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button {
            action()
        } label: {

            HStack {

                Text(title)
                    .font(
                        .system(
                            size: UIDevice.isPad ? 20 : 15,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: UIDevice.isPad ? 18 : 13,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        .gray.opacity(0.6)
                    )
            }
            .padding(.horizontal, UIDevice.isPad ? 28 : 18)
            .frame(height: UIDevice.isPad ? 70 : 52)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {

    ProfileView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
