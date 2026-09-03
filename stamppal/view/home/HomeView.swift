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

    // MARK: - SwiftData

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Postcard.id,
        order: .reverse
    )
    private var storedPostcards: [Postcard]

    // MARK: - UI State

    @State private var displayedPostcards: [Postcard] = []
    @State private var isSyncing = true

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            NavigationStack {

                ZStack {

                    // MARK: Background

                    PostCardBackgroundView()

                    // MARK: Content

                    if isSyncing {

                        ProgressView()
                            .controlSize(.large)

                    } else if displayedPostcards.isEmpty {

                        emptyState

                    } else {

                        PostcardStack(
                            postcards: displayedPostcards
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }

                    // MARK: Help Button

                    VStack {

                        HStack {

                            Spacer()

                            CircleIconButton(
                                icon: "questionmark"
                            ) {
                                helpTapped()
                            }
                        }
                        .padding(.horizontal, 42)
                        .padding(.top, 25)

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

    @MainActor
    private func syncGroupPostcards() async {

        isSyncing = true

        let groupCode =
            AuthenticationManager.shared.activeGroupCode

        print("================================")
        print("☁️ HOME CLOUDKIT SYNC")
        print("================================")

        print(
            "Active group code: \(groupCode ?? "NIL")"
        )

        // MARK: No Group

        guard let groupCode,
              !groupCode.isEmpty else {

            print("❌ NO ACTIVE GROUP CODE")

            displayedPostcards = storedPostcards

            isSyncing = false

            return
        }

        do {

            // MARK: Fetch CloudKit

            print("☁️ Fetching GroupPostcard...")
            print("☁️ Group code: \(groupCode)")

            let remoteCards =
                try await CloudKitGroupService.shared
                    .fetchGroupPostcards(
                        groupCode: groupCode
                    )

            print(
                "✅ CloudKit returned \(remoteCards.count) postcards"
            )

            // MARK: Print Results

            for card in remoteCards {

                print(
                    "☁️ Postcard ID:",
                    card.id.uuidString
                )

                print(
                    "Sender:",
                    card.sender
                )

                print(
                    "Recipient:",
                    card.recipient ?? "nil"
                )

                print(
                    "Message:",
                    card.message
                )

                print(
                    "Date:",
                    card.date
                )

                print(
                    "Group:",
                    card.groupCode ?? "nil"
                )

                print("-------------------------")
            }

            // MARK: Put CloudKit Cards Directly Into UI State

            displayedPostcards = remoteCards

            print(
                "📱 UI postcards:",
                displayedPostcards.count
            )

            // MARK: Save To SwiftData

            for remoteCard in remoteCards {

                let alreadyExists =
                    storedPostcards.contains {
                        $0.id == remoteCard.id
                    }

                if alreadyExists {

                    print(
                        "✓ Already exists:",
                        remoteCard.id.uuidString
                    )

                } else {

                    print(
                        "➕ Inserting postcard:",
                        remoteCard.id.uuidString
                    )

                    modelContext.insert(remoteCard)
                }
            }

            do {

                try modelContext.save()

                print("✅ SwiftData saved")

            } catch {

                print(
                    "❌ SwiftData save failed:",
                    error.localizedDescription
                )
            }

            // IMPORTANT:
            // The UI is already populated from remoteCards.
            // We don't need to wait for @Query to update.

            isSyncing = false

        } catch {

            print("❌ CloudKit fetch failed:")
            print(error)

            print(
                "Localized:",
                error.localizedDescription
            )

            // If CloudKit fails, show whatever is
            // already stored locally.

            displayedPostcards = storedPostcards

            isSyncing = false
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {

        VStack(spacing: 0) {

            VStack(spacing: 8) {

                Text(
                    "Kamu belum mendapatkan postcard"
                )
                .font(
                    .system(
                        size: 34,
                        weight: .bold
                    )
                )
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)

                Text(
                    "Tunggu hingga ada yang mengirimkan postcard"
                )
                .font(
                    .system(
                        size: 26,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            .padding(.top, 45)

            Spacer()

            Image("emptyPostcard")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 300,
                    height: 300
                )

            Spacer()
        }
        .frame(
            width: min(
                UIScreen.main.bounds.width * 0.62,
                1100
            ),
            height: 600
        )
        .background(Color.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
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
