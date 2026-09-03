//
//  InboxView.swift
//  stamppal
//

import SwiftUI
import SwiftData

struct InboxView: View {

    // MARK: - UI

    @State private var currentMode: GalleryMode = .masuk
    @State private var isSyncing = true
    @State private var selectedPostcard: Postcard?

    // This is what the UI actually displays.
    @State private var displayedPostcards: [Postcard] = []

    // MARK: - SwiftData

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \Postcard.id,
        order: .reverse
    )
    private var storedPostcards: [Postcard]

    // MARK: - Current User

    private var myUsername: String {
        AuthenticationManager.shared.username
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }

    private var myDisplayName: String {
        AuthenticationManager.shared.displayName
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .lowercased()
    }

    // MARK: - Sender Detection

    private func wasSentByMe(
        _ postcard: Postcard
    ) -> Bool {

        let sender =
            postcard.sender
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        let senderUsername =
            (postcard.senderUsername ?? "")
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
                .lowercased()

        // Username is the primary identifier.
        if !myUsername.isEmpty {

            if senderUsername == myUsername {
                return true
            }

            if sender == myUsername {
                return true
            }
        }

        // Display name fallback.
        if !myDisplayName.isEmpty {

            if sender == myDisplayName {
                return true
            }
        }

        return false
    }

    // MARK: - Mode Filtering

    private var cardsForMode: [Postcard] {

        switch currentMode {

        case .masuk:

            // ALL cards NOT sent by me.
            return displayedPostcards.filter { postcard in
                !wasSentByMe(postcard)
            }

        case .keluar:

            // ALL cards sent by me.
            return displayedPostcards.filter { postcard in
                wasSentByMe(postcard)
            }
        }
    }

    // MARK: - Date

    private var todayDateString: String {

        let formatter = DateFormatter()

        formatter.locale = Locale(
            identifier: "id_ID"
        )

        formatter.dateFormat = "dd MMMM yyyy"

        return formatter.string(
            from: Date()
        )
    }

    private var todayCards: [Postcard] {

        cardsForMode.filter {
            $0.date == todayDateString
        }
    }

    private var previousCards: [Postcard] {

        cardsForMode.filter {
            $0.date != todayDateString
        }
    }

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // -------------------------------------------------
                // FULL SCREEN BACKGROUND
                // -------------------------------------------------

                LinearGradient(
                    colors: [
                        Color(
                            red: 0.83,
                            green: 0.91,
                            blue: 1.0
                        ),
                        Color(
                            red: 0.88,
                            green: 0.94,
                            blue: 1.0
                        )
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(
                    spacing: 0
                ) {

                    // -------------------------------------------------
                    // HEADER
                    // -------------------------------------------------

                    headerView(
                        isPad: UIDevice.isPad,
                        width: geometry.size.width
                    )
                    .padding(
                        .top,
                        UIDevice.isPad ? 24 : 14
                    )
                    .padding(
                        .horizontal,
                        UIDevice.isPad ? 32 : 14
                    )
                    .padding(
                        .bottom,
                        UIDevice.isPad ? 28 : 16
                    )

                    // -------------------------------------------------
                    // CONTENT
                    // -------------------------------------------------

                    if isSyncing {

                        // -------------------------------------------------
                        // LOADING
                        //
                        // Header stays at the top.
                        // Loading is centered in the remaining space.
                        // -------------------------------------------------

                        VStack {

                            Spacer()

                            loadingState

                            Spacer()
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                    } else {

                        // -------------------------------------------------
                        // NORMAL CONTENT
                        // -------------------------------------------------

                        ScrollView(
                            .vertical,
                            showsIndicators: false
                        ) {

                            if cardsForMode.isEmpty {

                                emptyStateView(
                                    isPad: UIDevice.isPad
                                )
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: max(
                                        geometry.size.height - 120,
                                        300
                                    )
                                )

                            } else {

                                VStack(
                                    alignment: .leading,
                                    spacing: UIDevice.isPad
                                        ? 32
                                        : 20
                                ) {

                                    // -------------------------------------------------
                                    // TODAY
                                    // -------------------------------------------------

                                    if !todayCards.isEmpty {

                                        sectionBlock(
                                            title: "Hari ini",
                                            cards: todayCards,
                                            width: geometry.size.width
                                        )
                                    }

                                    // -------------------------------------------------
                                    // PREVIOUS
                                    // -------------------------------------------------

                                    if !previousCards.isEmpty {

                                        sectionBlock(
                                            title: "Kemarin",
                                            cards: previousCards,
                                            width: geometry.size.width
                                        )
                                    }
                                }
                                .padding(
                                    .horizontal,
                                    UIDevice.isPad ? 32 : 14
                                )
                                .padding(
                                    .bottom,
                                    UIDevice.isPad ? 40 : 24
                                )
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
            }
        }

        .navigationBarBackButtonHidden()

        // MARK: Fetch

        .task {
            await syncGroupPostcards()
        }

        // MARK: Refresh

        .refreshable {
            await syncGroupPostcards()
        }

        // MARK: - Postcard Detail Overlay

        .overlay {

            if let postcard = selectedPostcard {

                ZStack {

                    // Dark background
                    Color.black
                        .opacity(0.45)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {

                            withAnimation(
                                .easeInOut(duration: 0.2)
                            ) {
                                selectedPostcard = nil
                            }
                        }

                    // ONLY THE POSTCARD / IMAGE
                    ZStack(alignment: .topTrailing) {

                        PostcardView(
                            postcard: postcard
                        )
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: 700
                        )
                        .shadow(
                            color: .black.opacity(0.30),
                            radius: 30
                        )

                        // X button
                        Button {

                            withAnimation(
                                .easeInOut(duration: 0.2)
                            ) {
                                selectedPostcard = nil
                            }

                        } label: {

                            Image(systemName: "xmark")
                                .font(
                                    .system(
                                        size: 16,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.white)
                                .frame(
                                    width: 44,
                                    height: 44
                                )
                                .background(
                                    .black.opacity(0.55)
                                )
                                .clipShape(Circle())
                        }
                        .padding(18)
                    }
                    .frame(
                        maxWidth: 1000,
                        maxHeight: 700
                    )
                    .padding(24)
                    .offset(y: -50)
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }

    // MARK: - CloudKit Sync

    //
    // This intentionally follows HomeView's fetch flow.
    //
    // Difference:
    // Home -> displays unread cards only.
    // Inbox -> displays ALL cards.
    //

    @MainActor
    private func syncGroupPostcards() async {

        isSyncing = true

        let groupCode =
            AuthenticationManager.shared.activeGroupCode

        print("================================")
        print("☁️ INBOX CLOUDKIT SYNC")
        print("================================")

        print(
            "Active group code: \(groupCode ?? "NIL")"
        )

        // -------------------------------------------------
        // REQUIRE ACTIVE GROUP
        // -------------------------------------------------

        guard
            let groupCode,
            !groupCode.isEmpty
        else {

            print("❌ NO ACTIVE GROUP CODE")

            do {

                var descriptor =
                    FetchDescriptor<Postcard>(
                        sortBy: [
                            SortDescriptor(
                                \Postcard.id,
                                order: .reverse
                            )
                        ]
                    )

                descriptor.includePendingChanges = true

                displayedPostcards =
                    try modelContext.fetch(
                        descriptor
                    )

                print(
                    "📱 Showing \(displayedPostcards.count) local postcards"
                )

            } catch {

                print(
                    "❌ Failed to fetch local postcards:",
                    error.localizedDescription
                )

                displayedPostcards = []
            }

            isSyncing = false
            return
        }

        do {

            // -------------------------------------------------
            // 1. FETCH FROM CLOUDKIT
            // -------------------------------------------------

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

            // -------------------------------------------------
            // 2. FETCH CURRENT SWIFTDATA
            // -------------------------------------------------

            var localDescriptor =
                FetchDescriptor<Postcard>()

            localDescriptor.includePendingChanges = true

            let localCards =
                try modelContext.fetch(
                    localDescriptor
                )

            print(
                "💾 SwiftData currently has \(localCards.count) postcards"
            )

            // -------------------------------------------------
            // 3. INSERT MISSING CARDS
            // -------------------------------------------------

            for remoteCard in remoteCards {

                let exists =
                    localCards.contains {
                        $0.id == remoteCard.id
                    }

                if exists {

                    print(
                        "✓ Already exists: \(remoteCard.id.uuidString)"
                    )

                } else {

                    print(
                        "➕ Inserting postcard: \(remoteCard.id.uuidString)"
                    )

                    // New postcard is unread locally.
                    remoteCard.isRead = false

                    modelContext.insert(
                        remoteCard
                    )
                }
            }

            // -------------------------------------------------
            // 4. PROCESS PENDING CHANGES
            // -------------------------------------------------

            modelContext.processPendingChanges()

            // -------------------------------------------------
            // 5. SAVE
            // -------------------------------------------------

            if modelContext.hasChanges {

                print("💾 Saving SwiftData...")

                do {

                    try modelContext.save()

                    print(
                        "✅ SwiftData save SUCCESS"
                    )

                } catch {

                    print(
                        "❌❌❌ SWIFTDATA SAVE FAILED ❌❌❌"
                    )

                    print(
                        "Error:",
                        error
                    )

                    print(
                        "Localized:",
                        error.localizedDescription
                    )

                    // -------------------------------------------------
                    // IMPORTANT:
                    // CloudKit already gave us the correct cards.
                    // Show them immediately rather than showing
                    // an empty gallery.
                    // -------------------------------------------------

                    displayedPostcards = remoteCards

                    print(
                        "📱 Using CloudKit cards as UI fallback:"
                        + " \(displayedPostcards.count)"
                    )

                    isSyncing = false
                    return
                }

            } else {

                print(
                    "ℹ️ SwiftData has no pending changes"
                )
            }

            // -------------------------------------------------
            // 6. FETCH AGAIN AFTER SAVE
            // -------------------------------------------------

            var updatedDescriptor =
                FetchDescriptor<Postcard>(
                    sortBy: [
                        SortDescriptor(
                            \Postcard.id,
                            order: .reverse
                        )
                    ]
                )

            updatedDescriptor.includePendingChanges = true

            let updatedLocalCards =
                try modelContext.fetch(
                    updatedDescriptor
                )

            print(
                "💾 SwiftData after save:"
                + " \(updatedLocalCards.count) postcards"
            )

            // -------------------------------------------------
            // 7. BUILD UI DATA
            // -------------------------------------------------

            if !updatedLocalCards.isEmpty {

                displayedPostcards =
                    updatedLocalCards

                print(
                    "📱 Inbox cards shown:"
                    + " \(displayedPostcards.count)"
                )

            } else if !remoteCards.isEmpty {

                // -------------------------------------------------
                // SAFETY FALLBACK
                //
                // CloudKit definitely returned cards, so never
                // show an empty Inbox just because SwiftData
                // returned nothing.
                // -------------------------------------------------

                displayedPostcards =
                    remoteCards

                print(
                    "⚠️ SwiftData returned 0."
                )

                print(
                    "📱 Falling back to CloudKit cards:"
                    + " \(displayedPostcards.count)"
                )

            } else {

                displayedPostcards = []

                print(
                    "📱 No postcards available"
                )
            }

            // -------------------------------------------------
            // 8. DEBUG
            // -------------------------------------------------

            for card in displayedPostcards {

                print(
                    """
                    📮 CARD
                    ID: \(card.id.uuidString)
                    Sender: \(card.sender)
                    Username: \(card.senderUsername ?? "nil")
                    Is Me: \(wasSentByMe(card))
                    Is Read: \(card.isRead)
                    """
                )
            }

            isSyncing = false

        } catch {

            // -------------------------------------------------
            // CLOUDKIT / FETCH ERROR
            // -------------------------------------------------

            print(
                "❌ INBOX CLOUDKIT SYNC FAILED"
            )

            print(error)

            print(
                "Localized:",
                error.localizedDescription
            )

            // -------------------------------------------------
            // FALLBACK TO LOCAL SWIFTDATA
            // -------------------------------------------------

            do {

                var descriptor =
                    FetchDescriptor<Postcard>(
                        sortBy: [
                            SortDescriptor(
                                \Postcard.id,
                                order: .reverse
                            )
                        ]
                    )

                descriptor.includePendingChanges = true

                displayedPostcards =
                    try modelContext.fetch(
                        descriptor
                    )

                print(
                    "📱 Showing \(displayedPostcards.count)"
                    + " local postcards"
                )

            } catch {

                print(
                    "❌ Failed to fetch local postcards:",
                    error.localizedDescription
                )

                displayedPostcards = []
            }

            isSyncing = false
        }
    }

    // MARK: - Header

    @ViewBuilder
    private func headerView(
        isPad: Bool,
        width: CGFloat
    ) -> some View {

        HStack(
            alignment: .center,
            spacing: isPad ? 16 : 8
        ) {

            // -------------------------------------------------
            // ONLY HELP BUTTON
            // Home button removed.
            // -------------------------------------------------

            CircleIconButton(
                icon: "questionmark"
            ) {
                helpTapped()
            }

            Spacer(
                minLength: 4
            )

            // -------------------------------------------------
            // TITLE
            // -------------------------------------------------

            VStack(
                spacing: isPad ? 6 : 2
            ) {

                Text(
                    "Galeri Kartu Pos"
                )
                .font(
                    .system(
                        size: isPad ? 28 : 17,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 0.08,
                        green: 0.12,
                        blue: 0.22
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.85)

                if width > 500 {

                    Text(
                        "Lihat kembali pesan pesan bermakna"
                    )
                    .font(
                        .system(
                            size: isPad ? 14 : 11,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(
                        Color(
                            red: 0.08,
                            green: 0.12,
                            blue: 0.22
                        )
                        .opacity(0.65)
                    )
                    .lineLimit(1)
                }
            }

            Spacer(
                minLength: 4
            )

            // -------------------------------------------------
            // MODE TOGGLE
            // -------------------------------------------------

            ModeToggle(
                currentMode: $currentMode
            )
            .scaleEffect(
                isPad ? 1.0 : 0.85
            )
        }
    }

    // MARK: - Section

    private func sectionBlock(
        title: String,
        cards: [Postcard],
        width: CGFloat
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: UIDevice.isPad ? 14 : 10
        ) {

            SectionHeader(
                title: title
            )

            LazyVGrid(
                columns: columns(
                    for: width
                ),
                spacing: UIDevice.isPad ? 20 : 12
            ) {

                ForEach(
                    cards,
                    id: \.id
                ) { card in

                    Button {

                        print(
                            "📬 Postcard tapped: \(card.id.uuidString)"
                        )

                        selectedPostcard = card

                    } label: {

                        CardView(
                            postcard: card,
                            isIncoming:
                                currentMode == .masuk
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
    }

    // MARK: - Columns

    private func columns(
        for width: CGFloat
    ) -> [GridItem] {

        let count =
            width > 680
            ? 3
            : 2

        let spacing: CGFloat =
            UIDevice.isPad
            ? 20
            : 12

        return Array(
            repeating: GridItem(
                .flexible(),
                spacing: spacing
            ),
            count: count
        )
    }

    // MARK: - Loading State

    private var loadingState: some View {

        VStack(
            spacing: 20
        ) {

            ProgressView()
                .controlSize(.large)
                .scaleEffect(1.5)

            Text("Memuat galeri...")
                .font(
                    .system(
                        size: UIDevice.isPad ? 28 : 22,
                        weight: .semibold
                    )
                )
                .foregroundStyle(.black)

            Text("Tunggu sebentar ya")
                .font(
                    .system(
                        size: UIDevice.isPad ? 20 : 16,
                        weight: .regular
                    )
                )
                .foregroundStyle(.gray)
        }
    }

    // MARK: - Empty State

    private func emptyStateView(
        isPad: Bool
    ) -> some View {

        VStack(
            spacing: isPad ? 16 : 10
        ) {

            Image(
                systemName:
                    currentMode == .masuk
                    ? "tray"
                    : "paperplane"
            )
            .font(
                .system(
                    size: isPad ? 50 : 36
                )
            )
            .foregroundStyle(
                Color(
                    red: 0.08,
                    green: 0.12,
                    blue: 0.22
                )
                .opacity(0.35)
            )

            Text(
                currentMode == .masuk
                ? "Belum ada kartu pos masuk"
                : "Belum ada kartu pos keluar"
            )
            .font(
                .system(
                    size: isPad ? 22 : 17,
                    weight: .bold
                )
            )
            .foregroundStyle(
                Color(
                    red: 0.08,
                    green: 0.12,
                    blue: 0.22
                )
            )

            Text(
                currentMode == .masuk
                ? "Kartu pos yang kamu terima akan muncul di sini."
                : "Kartu pos yang kamu buat dan kirim akan muncul di sini."
            )
            .font(
                .system(
                    size: isPad ? 15 : 12
                )
            )
            .foregroundStyle(
                Color(
                    red: 0.08,
                    green: 0.12,
                    blue: 0.22
                )
                .opacity(0.6)
            )
            .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(
            .vertical,
            isPad ? 80 : 40
        )
    }

    // MARK: - Help

    private func helpTapped() {

        print(
            "❓ Help tapped"
        )
    }
}

// MARK: - Preview

#Preview("Galeri Kartu Pos") {

    let config =
        ModelConfiguration(
            isStoredInMemoryOnly: true
        )

    let container =
        try! ModelContainer(
            for: Postcard.self,
            configurations: config
        )

    for card in Postcard.samplePostcards {

        container.mainContext.insert(
            card
        )
    }

    return InboxView()
        .modelContainer(container)
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
