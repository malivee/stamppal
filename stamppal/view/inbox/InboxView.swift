//
//  InboxView.swift
//  stamppal
//

import SwiftUI

// MARK: - Postcard Model
struct PostcardItem: Identifiable {
    let id = UUID()
    let personName: String
    let date: String
    var imageName: String? = nil
}

// MARK: - Main Inbox View
struct InboxView: View {
    @State private var currentMode: GalleryMode = .masuk
    
    // MARK: - Data Dummy (Masuk)
    private let incomingTodayCards = [
        PostcardItem(personName: "Andrea Rodriguez", date: "01 August 2026"),
        PostcardItem(personName: "Alverz Belinza", date: "01 August 2026"),
        PostcardItem(personName: "Anita Michiko Tamala", date: "01 August 2026")
    ]
    
    private let incomingYesterdayCards = [
        PostcardItem(personName: "Anita Michiko Tamala", date: "01 August 2026"),
        PostcardItem(personName: "Andrea Rodriguez", date: "01 August 2026"),
        PostcardItem(personName: "Alverz Belinza", date: "01 August 2026")
    ]
    
    // MARK: - Data Dummy (Keluar)
    private let outgoingTodayCards = [
        PostcardItem(personName: "Alverz Belinza", date: "01 August 2026"),
        PostcardItem(personName: "Anita Michiko Tamala", date: "01 August 2026"),
        PostcardItem(personName: "Andrea Rodriguez", date: "01 August 2026")
    ]
    
    private let outgoingYesterdayCards = [
        PostcardItem(personName: "Alverz Belinza", date: "01 August 2026"),
        PostcardItem(personName: "Anita Michiko Tamala", date: "01 August 2026"),
        PostcardItem(personName: "Andrea Rodriguez", date: "01 August 2026")
    ]
    
    // Grid 3 kolom untuk tata letak iPad Landscape
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    private var todayCards: [PostcardItem] {
        currentMode == .masuk ? incomingTodayCards : outgoingTodayCards
    }
    
    private var yesterdayCards: [PostcardItem] {
        currentMode == .masuk ? incomingYesterdayCards : outgoingYesterdayCards
    }

    var body: some View {
        ZStack {
            // Latar belakang luar hitam (Safe Area)
            Color.black
                .ignoresSafeArea()

            // Kontainer Utama Berwarna Biru Muda dengan Sudut Melengkung
            VStack(spacing: 0) {
                // Header (Tombol Navigasi, Judul Tengah, & Toggle Masuk/Keluar)
                headerView
                    .padding(.top, 24)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 28)

                // Area Scroll Vertikal untuk Bagian Kartu
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        // Section: Hari ini
                        sectionBlock(title: "Hari ini", cards: todayCards)
                        
                        // Section: Kemarin
                        sectionBlock(title: "Kemarin", cards: yesterdayCards)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.83, green: 0.91, blue: 1.0),
                        Color(red: 0.88, green: 0.94, blue: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(20)
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .top) {
            // Tombol Kiri: Home & Info/Bantuan
            HStack(spacing: 14) {
                CircleIconButton(icon: "house.fill") {
                    // Action kembali ke Home
                }
                CircleIconButton(icon: "questionmark") {
                    // Action bantuan/info
                }
            }
            
            Spacer()
            
            // Judul & Subtitle Tengah
            VStack(spacing: 6) {
                Text("Galeri Kartu Pos")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                
                Text("Lihat kembali pesan pesan bermakna")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.65))
            }
            .offset(x: 20) // Menyeimbangkan posisi tepat di tengah
            
            Spacer()
            
            // Toggle Kanan: Masuk / Keluar
            ModeToggle(currentMode: $currentMode)
        }
    }
    
    // MARK: - Section Block (Judul + 3 Kolom Kartu)
    private func sectionBlock(title: String, cards: [PostcardItem]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: title)
            
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(cards) { card in
                    CardView(
                        personName: card.personName,
                        date: card.date,
                        isIncoming: currentMode == .masuk,
                        imageName: card.imageName
                    )
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Galeri Kartu Pos Masuk") {
    InboxView()
        .previewInterfaceOrientation(.landscapeLeft)
}

#Preview("Galeri Kartu Pos Keluar") {
    var view = InboxView()
    // Default view with preview
    view
        .previewInterfaceOrientation(.landscapeLeft)
}
