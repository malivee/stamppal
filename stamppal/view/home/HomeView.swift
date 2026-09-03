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
                        loadingState
                    } else if displayedPostcards.isEmpty {
                        emptyState
                    } else {
                        PostcardStack(
                            postcards: displayedPostcards,
                            onCardSwiped: { postcard in
                                markAsRead(postcard)
                            }
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
    
    //MARK: markAsRead
    @MainActor
    private func markAsRead(_ postcard: Postcard) {

        print("📖 Marking postcard as read:")
        print(postcard.id.uuidString)

        postcard.isRead = true

        displayedPostcards.removeAll {
            $0.id == postcard.id
        }

        do {
            try modelContext.save()
            print("✅ Postcard marked as read")
        } catch {
            print(
                "❌ Failed to save read state:",
                error.localizedDescription
            )
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

        guard
            let groupCode,
            !groupCode.isEmpty
        else {

            print("❌ NO ACTIVE GROUP CODE")

            displayedPostcards =
                storedPostcards.filter {
                    !$0.isRead
                }

            isSyncing = false
            return
        }

        do {

            // -------------------------------------------------
            // FETCH FROM CLOUDKIT
            // -------------------------------------------------

            print(
                "☁️ Fetching GroupPostcard..."
            )

            print(
                "☁️ Group code: \(groupCode)"
            )

            let remoteCards =
                try await CloudKitGroupService.shared
                    .fetchGroupPostcards(
                        groupCode: groupCode
                    )

            print(
                "📥 CloudKit returned \(remoteCards.count) postcards"
            )

            // -------------------------------------------------
            // FETCH CURRENT SWIFTDATA DIRECTLY
            //
            // Do NOT rely on @Query here.
            // -------------------------------------------------

            let descriptor =
                FetchDescriptor<Postcard>()

            let localCards =
                try modelContext.fetch(
                    descriptor
                )

            print(
                "💾 SwiftData currently has \(localCards.count) postcards"
            )

            // -------------------------------------------------
            // INSERT ONLY CARDS THAT DON'T EXIST
            // -------------------------------------------------

            for remoteCard in remoteCards {

                if let existingCard =
                    localCards.first(
                        where: {
                            $0.id == remoteCard.id
                        }
                    ) {

                    print(
                        "✓ Already exists: \(existingCard.id.uuidString)"
                    )

                    print(
                        "   isRead = \(existingCard.isRead)"
                    )

                } else {

                    print(
                        "➕ Inserting postcard: \(remoteCard.id.uuidString)"
                    )

                    // New postcard starts unread.
                    remoteCard.isRead = false

                    modelContext.insert(
                        remoteCard
                    )
                }
            }

            // -------------------------------------------------
            // SAVE
            // -------------------------------------------------

            if modelContext.hasChanges {

                try modelContext.save()

                print(
                    "✅ SwiftData save complete"
                )
            }

            // -------------------------------------------------
            // FETCH AGAIN AFTER SAVE
            //
            // This is important.
            // We now get the actual persisted objects,
            // including their local isRead values.
            // -------------------------------------------------

            let updatedLocalCards =
                try modelContext.fetch(
                    FetchDescriptor<Postcard>(
                        sortBy: [
                            SortDescriptor(
                                \Postcard.id,
                                order: .reverse
                            )
                        ]
                    )
                )

            // -------------------------------------------------
            // BUILD HOME
            //
            // Home only shows unread cards.
            // -------------------------------------------------

            displayedPostcards =
                updatedLocalCards.filter {
                    !$0.isRead
                }

            print(
                "📱 Unread postcards shown: \(displayedPostcards.count)"
            )

            // Debug every card.
            for card in updatedLocalCards {

                print(
                    "📮 \(card.id.uuidString) | isRead = \(card.isRead)"
                )
            }

            isSyncing = false

        } catch {

            print(
                "❌ HOME CLOUDKIT SYNC FAILED"
            )

            print(
                error
            )

            print(
                "Localized:",
                error.localizedDescription
            )

            // -------------------------------------------------
            // FALLBACK TO LOCAL DATA
            // -------------------------------------------------

            do {

                let localCards =
                    try modelContext.fetch(
                        FetchDescriptor<Postcard>(
                            sortBy: [
                                SortDescriptor(
                                    \Postcard.id,
                                    order: .reverse
                                )
                            ]
                        )
                    )

                displayedPostcards =
                    localCards.filter {
                        !$0.isRead
                    }

            } catch {

                displayedPostcards = []

                print(
                    "❌ Failed to fetch local postcards:",
                    error.localizedDescription
                )
            }

            isSyncing = false
        }
    }
    
    // MARK: - Loading State

    private var loadingState: some View {
        VStack(spacing: 24) {
            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.5)
                .foregroundStyle(.blue)
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
