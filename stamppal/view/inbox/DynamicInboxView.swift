//
//  DynamicInboxView.swift
//  stamppal
//

import SwiftUI

// MARK: - Timeframe Enum
enum InboxTimeframe: String, Hashable {
    case today = "Hari ini"
    case lastMonth = "Bulan lalu"
    case lastYear = "Tahun lalu"
}

// MARK: - Data Model
struct StampCardItem: Identifiable {
    let id = UUID()
    let sender: String
    let date: String
}

// MARK: - Main Dynamic View
struct DynamicInboxView: View {
    @Environment(\.dismiss) private var dismiss
    
    let timeframe: InboxTimeframe
    
    // Data dummy
    let items: [StampCardItem] = [
        StampCardItem(sender: "Andrea Rodriguez", date: "01 August 2026"),
        StampCardItem(sender: "Alverz Belinza", date: "01 August 2026"),
        StampCardItem(sender: "Anita Michiko Tamala", date: "01 August 2026"),
        StampCardItem(sender: "Andrea Rodriguez", date: "01 August 2026"),
        StampCardItem(sender: "Alverz Belinza", date: "01 August 2026"),
        StampCardItem(sender: "Anita Michiko Tamala", date: "01 August 2026")
    ]
    
    // Grid 3 kolom untuk iPad
    private let columns = [
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24),
        GridItem(.flexible(), spacing: 24)
    ]

    var body: some View {
        ZStack {
            // Latar belakang hitam luar (Safe Area)
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header Bar
                HStack(spacing: 16) {
                    CircleIconButton(icon: "chevron.left") {
                        dismiss()
                    }

                    Text(timeframe.rawValue)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))

                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                .padding(.bottom, 24)

                // Grid Kartu
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(items) { item in
                            CardView(
                                personName: item.sender,
                                date: item.date,
                                isIncoming: true
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 0.83, green: 0.91, blue: 1.0), Color(red: 0.88, green: 0.94, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .padding(20)

            // Tombol Melayang di Bawah
            VStack {
                Spacer()

                Button(action: {
                    // Action untuk membuat kartu baru
                }) {
                    Text("Ketuk di Sini Untuk Membuat Kartu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.06, green: 0.14, blue: 0.36))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 80)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
#Preview("Hari Ini") {
    DynamicInboxView(timeframe: .today)
        .previewInterfaceOrientation(.landscapeLeft)
}

#Preview("Bulan Lalu") {
    DynamicInboxView(timeframe: .lastMonth)
        .previewInterfaceOrientation(.landscapeLeft)
}

#Preview("Tahun Lalu") {
    DynamicInboxView(timeframe: .lastYear)
        .previewInterfaceOrientation(.landscapeLeft)
}
