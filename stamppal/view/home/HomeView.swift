//
//  HomeView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI
import UIKit
import SwiftData

struct HomeView: View {

    // MARK: - Postcards from SwiftData

    @Environment(\.modelContext) private var modelContext
    @Query(
        sort: \Postcard.id,
        order: .reverse
    )
    private var postcards: [Postcard]

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            NavigationStack {

                ZStack {

                    // MARK: - Background

                    PostCardBackgroundView()

                    // MARK: - Postcard Stack

                    if postcards.isEmpty {

                        emptyState

                    } else {

                        PostcardStack(
                            postcards: postcards
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }

                    // MARK: - Help Button

                    VStack {

                        HStack {

                            Spacer()

                            CircleIconButton(
                                icon: "questionmark"
                            ) {
                                helpTapped()
                            }
                        }
                        .padding(
                            .horizontal,
                            42
                        )
                        .padding(
                            .top,
                            25
                        )

                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .task {
            await syncGroupPostcards()
        }
        .refreshable {
            await syncGroupPostcards()
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
            print("ℹ️ Sync group postcards: \(error.localizedDescription)")
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {

        VStack(spacing: 12) {

            Image(systemName: "envelope")
                .font(.system(size: 55))
                .foregroundStyle(.gray)

            Text("Belum ada kartu pos")
                .font(
                    .system(
                        size: 28,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.black)

            Text("Kartu pos yang kamu terima akan muncul di sini.")
                .font(
                    .system(
                        size: 18,
                        weight: .regular
                    )
                )
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, UIDevice.isPad ? 80 : 32)
        .padding(.vertical, UIDevice.isPad ? 80 : 36)
        .frame(maxWidth: UIDevice.isPad ? 500 : 320)
        .background {
            Color.white
        }
        .clipShape(RoundedRectangle(cornerRadius: UIDevice.isPad ? 30 : 20))
        .padding(.horizontal, UIDevice.isPad ? 40 : 20)
        .shadow(radius: 16)
    }

    // MARK: - Actions

    private func helpTapped() {
        print("Help tapped")
    }
}

// MARK: - Preview

#Preview {

    HomeView()
        .modelContainer(
            for: Postcard.self,
            inMemory: true
        )
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
