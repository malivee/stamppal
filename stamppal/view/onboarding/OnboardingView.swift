//
//  OnboardingView.swift
//  stamppal
//
//  Tampilan Onboarding:
//  - Menggunakan CloudKit Silent Authentication (tanpa tombol Sign in with Apple standar).
//  - Langsung menampilkan tombol "join" dan "create" sesuai desain mockup.
//  - Jika pengguna baru terdeteksi di CloudKit, pop-up pendaftaran username & tanggal lahir akan muncul otomatis.
//

import SwiftUI

// MARK: - Slide Model
struct OnboardingSlideItem: Identifiable {
    let id: Int
    let imageName: String
    let title: String
    let subtitle: String
}

// MARK: - Onboarding View
struct OnboardingView: View {
    var onJoin: (() -> Void)?
    var onCreate: (() -> Void)?
    
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var currentSlideIndex: Int = 0
    @State private var showingCreateGroupSheet: Bool = false
    @State private var showingJoinGroupSheet: Bool = false
    
    private let slides: [OnboardingSlideItem] = [
        OnboardingSlideItem(
            id: 0,
            imageName: "slide2",
            title: "Saling berinteraksi dengan postcard",
            subtitle: "Kirim dan terima postcard berisi foto, pesan, dan dapatkan prangko yang sesuai."
        ),
        OnboardingSlideItem(
            id: 1,
            imageName: "slide1",
            title: "Selamat Datang!",
            subtitle: "Temukan cara baru untuk berinteraksi dengan orang tersayang."
        ),
        OnboardingSlideItem(
            id: 2,
            imageName: "slide3",
            title: "Mari mulai berinteraksi",
            subtitle: "Kirim dan terima postcard bersama keluarga dan teman terdekat."
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let isPad = UIDevice.isPad
            let cardPadding: CGFloat = isPad ? 20 : 10
            let cornerRadius: CGFloat = isPad ? 32 : 22
            
            ZStack {
                // Latar Belakang Luar Hitam
                Color.black
                    .ignoresSafeArea()
                
                // Kontainer Utama Bergradasi Biru Muda
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.83, green: 0.91, blue: 1.0),
                            Color(red: 0.88, green: 0.94, blue: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    VStack(spacing: 0) {
                        Spacer(minLength: isPad ? 16 : 8)
                        
                        // MARK: - Area Slide & Navigasi Panah
                        ZStack {
                            TabView(selection: $currentSlideIndex) {
                                ForEach(slides) { slide in
                                    slideContentView(for: slide, geometry: geometry)
                                        .tag(slide.id)
                                }
                            }
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            
                            // Panah Kiri
                            if currentSlideIndex > 0 {
                                HStack {
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            currentSlideIndex -= 1
                                        }
                                    } label: {
                                        arrowCircleButton(icon: "chevron.left", isPad: isPad)
                                    }
                                    .padding(.leading, isPad ? 36 : 14)
                                    
                                    Spacer()
                                }
                            }
                            
                            // Panah Kanan
                            if currentSlideIndex < slides.count - 1 {
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            currentSlideIndex += 1
                                        }
                                    } label: {
                                        arrowCircleButton(icon: "chevron.right", isPad: isPad)
                                    }
                                    .padding(.trailing, isPad ? 36 : 14)
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                        
                        // MARK: - Indikator Titik Halaman
                        pageIndicatorView
                            .padding(.bottom, isPad ? 18 : 12)
                        
                        // MARK: - Tombol Aksi "join" & "create"
                        actionButtons(isPad: isPad)
                            .padding(.bottom, isPad ? 28 : 16)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .padding(cardPadding)
            }
            // Sheet Buat Grup Baru
            .sheet(isPresented: $showingCreateGroupSheet) {
                CreateGroupSheet {
                    onCreate?()
                }
            }
            // Sheet Gabung Grup dengan ID
            .sheet(isPresented: $showingJoinGroupSheet) {
                JoinGroupSheet {
                    onJoin?()
                }
            }
            // Sheet Pop-up Registrasi Pengguna Baru CloudKit
            .sheet(isPresented: $authManager.needsProfileRegistration) {
                NewUserRegistrationSheet {
                    authManager.needsProfileRegistration = false
                }
            }
        }
    }
    
    // MARK: - Slide Content View
    @ViewBuilder
    private func slideContentView(for slide: OnboardingSlideItem, geometry: GeometryProxy) -> some View {
        let isPad = UIDevice.isPad
        let imageHeight: CGFloat = isPad ? 260 : min(geometry.size.height * 0.34, 160)
        
        VStack(spacing: 0) {
            Spacer()
            
            Image(slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: imageHeight)
                .padding(.horizontal, isPad ? 40 : 20)
            
            Spacer()
                .frame(height: isPad ? 20 : 10)
            
            Text(slide.title)
                .font(.system(size: isPad ? 30 : 20, weight: .bold))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                .multilineTextAlignment(.center)
                .padding(.horizontal, isPad ? 40 : 20)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            Spacer()
                .frame(height: isPad ? 10 : 6)
            
            Text(slide.subtitle)
                .font(.system(size: isPad ? 16 : 12, weight: .regular))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.65))
                .multilineTextAlignment(.center)
                .lineSpacing(isPad ? 4 : 2)
                .frame(maxWidth: isPad ? 500 : 320)
                .padding(.horizontal, isPad ? 40 : 20)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
            
            Spacer()
        }
    }
    
    // MARK: - Action Buttons (join & create)
    private func actionButtons(isPad: Bool) -> some View {
        VStack(spacing: isPad ? 12 : 8) {
            // Button 1: "join"
            Button {
                showingJoinGroupSheet = true
            } label: {
                Text("join")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: isPad ? 340 : 280)
                    .frame(height: isPad ? 50 : 42)
                    .background(Color(red: 0.03, green: 0.06, blue: 0.35))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            
            // Button 2: "create"
            Button {
                showingCreateGroupSheet = true
            } label: {
                Text("create")
                    .font(.system(size: isPad ? 17 : 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: isPad ? 340 : 280)
                    .frame(height: isPad ? 50 : 42)
                    .background(Color(red: 0.03, green: 0.06, blue: 0.35))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.16), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Circular Arrow Button Component
    private func arrowCircleButton(icon: String, isPad: Bool) -> some View {
        let size: CGFloat = isPad ? 44 : 34
        let iconSize: CGFloat = isPad ? 16 : 12
        
        return Image(systemName: icon)
            .font(.system(size: iconSize, weight: .bold))
            .foregroundColor(Color(red: 0.08, green: 0.14, blue: 0.28))
            .frame(width: size, height: size)
            .background(Color.white.opacity(0.92))
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Page Indicator Dots
    private var pageIndicatorView: some View {
        HStack(spacing: 8) {
            ForEach(0..<slides.count, id: \.self) { index in
                if currentSlideIndex == index {
                    Capsule()
                        .fill(Color(red: 0.12, green: 0.16, blue: 0.28))
                        .frame(width: UIDevice.isPad ? 22 : 16, height: UIDevice.isPad ? 6 : 5)
                } else {
                    Circle()
                        .fill(Color(red: 0.12, green: 0.16, blue: 0.28).opacity(0.25))
                        .frame(width: UIDevice.isPad ? 6 : 5, height: UIDevice.isPad ? 6 : 5)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentSlideIndex)
    }
}

// MARK: - Previews
#Preview {
    OnboardingView()
}
