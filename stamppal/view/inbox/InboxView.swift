//
//  InboxView.swift
//  stamppal
//

import SwiftUI
import SwiftData

// MARK: - Main Inbox View
struct InboxView: View {
    @State private var currentMode: GalleryMode = .masuk
    
    // MARK: - Postcards from SwiftData
    @Query(
        sort: \Postcard.id,
        order: .reverse
    )
    private var postcards: [Postcard]
    
    @Environment(\.modelContext) private var modelContext
    
    private func columns(for width: CGFloat) -> [GridItem] {
        let count = width > 680 ? 3 : 2
        let spacing: CGFloat = UIDevice.isPad ? 20 : 12
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: count)
    }
    
    private var cardsForMode: [Postcard] {
        let auth = AuthenticationManager.shared
        let myUsername = auth.username.lowercased()
        let myDisplayName = auth.displayName.lowercased()
        
        switch currentMode {
        case .masuk:
            return postcards.filter { card in
                let sender = card.sender.lowercased()
                let senderUname = (card.senderUsername ?? "").lowercased()
                let isMe = (!myUsername.isEmpty && (senderUname == myUsername || sender == myUsername)) ||
                           (!myDisplayName.isEmpty && sender == myDisplayName) ||
                           sender == "user"
                return !isMe
            }
        case .keluar:
            return postcards.filter { card in
                let sender = card.sender.lowercased()
                let senderUname = (card.senderUsername ?? "").lowercased()
                let isMe = (!myUsername.isEmpty && (senderUname == myUsername || sender == myUsername)) ||
                           (!myDisplayName.isEmpty && sender == myDisplayName) ||
                           sender == "user"
                return isMe
            }
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter.string(from: Date())
    }
    
    private var todayCards: [Postcard] {
        cardsForMode.filter { $0.date == todayDateString }
    }
    
    private var yesterdayCards: [Postcard] {
        cardsForMode.filter { $0.date != todayDateString }
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = UIDevice.isPad
            let cardPadding: CGFloat = isPad ? 20 : 10
            let cornerRadius: CGFloat = isPad ? 32 : 22
            let contentHPad: CGFloat = isPad ? 32 : 14
            
            ZStack {
                // Latar belakang luar hitam (Safe Area)
                Color.black
                    .ignoresSafeArea()

                // Kontainer Utama Berwarna Biru Muda dengan Sudut Melengkung
                VStack(spacing: 0) {
                    // Header (Tombol Navigasi, Judul Tengah, & Toggle Masuk/Keluar)
                    headerView(isPad: isPad, width: geometry.size.width)
                        .padding(.top, isPad ? 24 : 14)
                        .padding(.horizontal, contentHPad)
                        .padding(.bottom, isPad ? 28 : 16)

                    // Area Scroll Vertikal untuk Bagian Kartu
                    ScrollView(.vertical, showsIndicators: false) {
                        if cardsForMode.isEmpty {
                            emptyStateView(isPad: isPad)
                        } else {
                            VStack(alignment: .leading, spacing: isPad ? 32 : 20) {
                                // Section: Hari ini
                                if !todayCards.isEmpty {
                                    sectionBlock(title: "Hari ini", cards: todayCards, width: geometry.size.width)
                                }
                                
                                // Section: Kemarin / Sebelumnya
                                if !yesterdayCards.isEmpty {
                                    sectionBlock(title: "Kemarin", cards: yesterdayCards, width: geometry.size.width)
                                }
                            }
                            .padding(.horizontal, contentHPad)
                            .padding(.bottom, isPad ? 40 : 24)
                        }
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
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .padding(cardPadding)
            }
            .task {
                await syncGroupPostcards()
            }
            .refreshable {
                await syncGroupPostcards()
            }
        }
    }
    
    // MARK: - Sync Group Postcards
    private func syncGroupPostcards() async {
        guard let groupCode = AuthenticationManager.shared.activeGroupCode, !groupCode.isEmpty else { return }
        do {
            let remoteCards = try await CloudKitGroupService.shared.fetchGroupPostcards(groupCode: groupCode)
            await MainActor.run {
                for card in remoteCards {
                    let exists = postcards.contains(where: { $0.id == card.id })
                    if !exists {
                        modelContext.insert(card)
                    }
                }
                try? modelContext.save()
            }
        } catch {
            print("ℹ️ Sync group postcards in Inbox: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Empty State View
    private func emptyStateView(isPad: Bool) -> some View {
        VStack(spacing: isPad ? 16 : 10) {
            Image(systemName: currentMode == .masuk ? "tray" : "paperplane")
                .font(.system(size: isPad ? 50 : 36))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.35))
            
            Text(currentMode == .masuk ? "Belum ada kartu pos masuk" : "Belum ada kartu pos keluar")
                .font(.system(size: isPad ? 22 : 17, weight: .bold))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
            
            Text(currentMode == .masuk
                 ? "Kartu pos yang kamu terima akan muncul di sini."
                 : "Kartu pos yang kamu buat dan kirim akan muncul di sini.")
                .font(.system(size: isPad ? 15 : 12, weight: .regular))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isPad ? 80 : 40)
    }
    
    // MARK: - Header View
    @ViewBuilder
    private func headerView(isPad: Bool, width: CGFloat) -> some View {
        HStack(alignment: .center, spacing: isPad ? 16 : 8) {
            // Tombol Kiri: Home & Info/Bantuan
            HStack(spacing: isPad ? 14 : 8) {
                CircleIconButton(icon: "house.fill")
                CircleIconButton(icon: "questionmark")
            }
            
            Spacer(minLength: 4)
            
            // Judul & Subtitle Tengah
            VStack(spacing: isPad ? 6 : 2) {
                Text("Galeri Kartu Pos")
                    .font(.system(size: isPad ? 28 : 17, weight: .bold))
                    .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                
                if width > 500 {
                    Text("Lihat kembali pesan pesan bermakna")
                        .font(.system(size: isPad ? 14 : 11, weight: .regular))
                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22).opacity(0.65))
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 4)
            
            // Toggle Kanan: Masuk / Keluar
            ModeToggle(currentMode: $currentMode)
                .scaleEffect(isPad ? 1.0 : 0.85)
        }
    }
    
    // MARK: - Section Block (Judul + Kolom Kartu)
    private func sectionBlock(title: String, cards: [Postcard], width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: UIDevice.isPad ? 14 : 10) {
            SectionHeader(title: title)
            
            LazyVGrid(columns: columns(for: width), spacing: UIDevice.isPad ? 20 : 12) {
                ForEach(cards, id: \.id) { card in
                    CardView(
                        postcard: card,
                        isIncoming: currentMode == .masuk
                    )
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Galeri Kartu Pos") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Postcard.self, configurations: config)
    for card in Postcard.samplePostcards {
        container.mainContext.insert(card)
    }
    
    return InboxView()
        .modelContainer(container)
}
