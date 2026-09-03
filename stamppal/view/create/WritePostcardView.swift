import SwiftUI
import UIKit
import FoundationModels
import SwiftData

struct WritePostcardView: View {

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - Image

    @State private var selectedImage: UIImage?

    @Binding var selectedTab: Int

    @State private var aiUnavailableMessage: String?

    // MARK: - Text

    @State private var recipient = "Andrea Rodriguez"
    @State private var message = ""

    // MARK: - Stamp

    @State private var generatedStamp: UIImage?
    @State private var isGeneratingStamp = false
    @State private var stampError: String?

    // MARK: - Navigation

    @Environment(\.dismiss)
    private var dismiss

    @State private var isCameraPresented = false

    // MARK: - Initializer

    init(
        image: UIImage? = nil,
        selectedTab: Binding<Int>
    ) {
        _selectedImage = State(
            initialValue: image
        )

        _selectedTab = selectedTab
    }

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                // MARK: Background

                background

                VStack(spacing: 0) {

                    // MARK: Header

                    header
                        .padding(
                            .top,
                            UIDevice.isPad ? 10 : 4
                        )

                    Spacer(
                        minLength:
                            UIDevice.isPad
                            ? 25
                            : 10
                    )

                    // MARK: Postcard

                    postcard(
                        geometry: geometry
                    )

                    Spacer(
                        minLength:
                            UIDevice.isPad
                            ? 35
                            : 12
                    )

                    // MARK: Send Button

                    HStack(spacing: 0) {

                        Spacer()

                        sendButton
                            .frame(
                                width:
                                    geometry.size.width
                                    * 0.61
                            )
                    }

                    Spacer(
                        minLength:
                            UIDevice.isPad
                            ? 25
                            : 8
                    )
                }
                .padding(
                    .horizontal,
                    UIDevice.isPad
                    ? 42
                    : 14
                )
            }
        }

        .navigationBarBackButtonHidden()

        .toolbar(
            .hidden,
            for: .tabBar
        )

        // MARK: Camera

        .fullScreenCover(
            isPresented: $isCameraPresented
        ) {

            CameraViewControllerWrapper { image in

                selectedImage = image
                isCameraPresented = false
            }
            .ignoresSafeArea()
        }

        // MARK: AI Error Alert

        .alert(
            "AI Tidak Tersedia",
            isPresented: Binding(
                get: {
                    aiUnavailableMessage != nil
                },
                set: { newValue in
                    if !newValue {
                        aiUnavailableMessage = nil
                    }
                }
            )
        ) {

            Button("OK") {
                aiUnavailableMessage = nil
            }

        } message: {

            Text(
                aiUnavailableMessage
                ?? "Terjadi kesalahan."
            )
        }

        // MARK: Stamp Error Alert

        .alert(
            "Gagal Membuat Prangko",
            isPresented: Binding(
                get: {
                    stampError != nil
                },
                set: { newValue in
                    if !newValue {
                        stampError = nil
                    }
                }
            )
        ) {

            Button("OK") {
                stampError = nil
            }

        } message: {

            Text(
                stampError
                ?? "Terjadi kesalahan saat membuat prangko."
            )
        }
    }

    // MARK: - Background

    private var background: some View {

        LinearGradient(
            stops: [

                .init(
                    color: Color(
                        red: 0.72,
                        green: 0.85,
                        blue: 0.98
                    ),
                    location: 0
                ),

                .init(
                    color: Color(
                        red: 0.84,
                        green: 0.92,
                        blue: 1.0
                    ),
                    location: 0.70
                ),

                .init(
                    color: .white,
                    location: 1
                )
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {

        HStack {

            // -------------------------------------------------
            // HOME
            // -------------------------------------------------

            Button {

                selectedTab = 0
                dismiss()

            } label: {

                Image(
                    systemName: "house.fill"
                )
                .font(
                    .system(
                        size:
                            UIDevice.isPad
                            ? 30
                            : 18,
                        weight: .medium
                    )
                )
                .foregroundStyle(.black)
                .frame(
                    width:
                        UIDevice.isPad
                        ? 68
                        : 42,
                    height:
                        UIDevice.isPad
                        ? 68
                        : 42
                )
                .background(
                    Circle()
                        .fill(
                            .white.opacity(0.45)
                        )
                )
                .overlay(
                    Circle()
                        .stroke(
                            .white.opacity(0.7),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)

            Spacer()

            // -------------------------------------------------
            // TITLE
            // -------------------------------------------------

            VStack(spacing: 2) {

                Text("Tulis Postcard")
                    .font(
                        .system(
                            size:
                                UIDevice.isPad
                                ? 40
                                : 22,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(
                    "Tulis pesan bermakna untuk orang tersayang"
                )
                .font(
                    .system(
                        size:
                            UIDevice.isPad
                            ? 24
                            : 12,
                        weight: .medium
                    )
                )
                .foregroundStyle(.gray)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            }

            Spacer()

            // -------------------------------------------------
            // HELP
            // -------------------------------------------------

            Button {

                helpTapped()

            } label: {

                Text("?")
                    .font(
                        .system(
                            size:
                                UIDevice.isPad
                                ? 30
                                : 18,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width:
                            UIDevice.isPad
                            ? 68
                            : 42,
                        height:
                            UIDevice.isPad
                            ? 68
                            : 42
                    )
                    .background(
                        Circle()
                            .fill(
                                .white.opacity(0.45)
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                .white.opacity(0.7),
                                lineWidth: 1
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Postcard

    private func postcard(
        geometry: GeometryProxy
    ) -> some View {

        HStack(
            spacing: 0
        ) {

            // =================================================
            // IMAGE
            // =================================================

            ZStack {

                if let selectedImage {

                    Image(
                        uiImage: selectedImage
                    )
                    .resizable()
                    .scaledToFill()

                } else {

                    Image(
                        "placeholderImage"
                    )
                    .resizable()
                    .scaledToFill()
                }
            }
            .frame(
                width:
                    geometry.size.width
                    * 0.39
            )
            .frame(
                maxHeight: .infinity
            )
            .clipped()
            .clipShape(
                RoundedRectangle(
                    cornerRadius:
                        UIDevice.isPad
                        ? 16
                        : 12,
                    style: .continuous
                )
            )

            // =================================================
            // CAMERA BUTTON
            // =================================================

            .overlay(
                alignment: .bottom
            ) {

                Button {

                    openCamera()

                } label: {

                    Image(
                        systemName:
                            "camera.fill"
                    )
                    .font(
                        .system(
                            size:
                                UIDevice.isPad
                                ? 25
                                : 16,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width:
                            UIDevice.isPad
                            ? 82
                            : 46,
                        height:
                            UIDevice.isPad
                            ? 82
                            : 46
                    )
                    .background(
                        Circle()
                            .fill(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.35),
                                lineWidth:
                                    UIDevice.isPad
                                    ? 4
                                    : 2.5
                            )
                    )
                }
                .buttonStyle(.plain)
                .offset(
                    y:
                       -10
                )
            }

            // =================================================
            // WRITING AREA
            // =================================================

            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                // -------------------------------------------------
                // RECIPIENT / DATE / STAMP
                // -------------------------------------------------

                HStack(
                    alignment: .top
                ) {

                    // ---------------------------------------------
                    // RECIPIENT
                    // ---------------------------------------------

                    VStack(
                        alignment: .leading,
                        spacing:
                            UIDevice.isPad
                            ? 6
                            : 4
                    ) {

                        HStack(
                            spacing:
                                UIDevice.isPad
                                ? 8
                                : 5
                        ) {

                            // Recipient avatar
                            Circle()
                                .fill(
                                    Color(
                                        red: 0.78,
                                        green: 0.63,
                                        blue: 0.43
                                    )
                                )
                                .frame(
                                    width:
                                        UIDevice.isPad
                                        ? 24
                                        : 18,
                                    height:
                                        UIDevice.isPad
                                        ? 24
                                        : 18
                                )

                            Text(
                                recipient.isEmpty
                                ? "Pilih penerima"
                                : recipient
                            )
                            .font(
                                .system(
                                    size:
                                        UIDevice.isPad
                                        ? 23
                                        : 14,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(
                                recipient.isEmpty
                                ? .gray
                                : .black
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                            // X
                            if !recipient.isEmpty {

                                Button {

                                    recipient = ""

                                } label: {

                                    Image(
                                        systemName:
                                            "xmark"
                                    )
                                    .font(
                                        .system(
                                            size:
                                                UIDevice.isPad
                                                ? 14
                                                : 10,
                                            weight: .semibold
                                        )
                                    )
                                    .foregroundStyle(
                                        .black.opacity(0.75)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(
                            .horizontal,
                            UIDevice.isPad
                            ? 10
                            : 7
                        )
                        .padding(
                            .vertical,
                            UIDevice.isPad
                            ? 5
                            : 3
                        )
                        .background(
                            Capsule()
                                .fill(.white)
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    Color.black.opacity(0.25),
                                    lineWidth: 1
                                )
                        )

                        Text(currentDate)
                            .font(
                                .system(
                                    size:
                                        UIDevice.isPad
                                        ? 20
                                        : 11,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }

                    Spacer()

                    // ---------------------------------------------
                    // AI STAMP
                    // ---------------------------------------------

                    VStack(
                        spacing:
                            UIDevice.isPad
                            ? 8
                            : 4
                    ) {

                        ZStack {

                            // -------------------------------------
                            // STAMP IMAGE
                            // -------------------------------------

                            if let generatedStamp {

                                Image(
                                    uiImage:
                                        generatedStamp
                                )
                                .resizable()
                                .scaledToFill()
                                .clipped()

                            } else {

                                Rectangle()
                                    .fill(
                                        Color(
                                            red: 0.76,
                                            green: 0.76,
                                            blue: 0.79
                                        )
                                    )

                                Text("Prangko")
                                    .font(
                                        .system(
                                            size:
                                                UIDevice.isPad
                                                ? 23
                                                : 13,
                                            weight: .regular
                                        )
                                    )
                                    .foregroundStyle(
                                        Color(
                                            red: 0.40,
                                            green: 0.40,
                                            blue: 0.42
                                        )
                                    )
                            }

                            // -------------------------------------
                            // GENERATING OVERLAY
                            // -------------------------------------

                            if isGeneratingStamp {

                                Rectangle()
                                    .fill(
                                        .black.opacity(0.35)
                                    )

                                VStack(spacing: 6) {

                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(
                                            UIDevice.isPad
                                            ? 1.2
                                            : 0.8
                                        )

                                    Text("Membuat...")
                                        .font(
                                            .system(
                                                size:
                                                    UIDevice.isPad
                                                    ? 14
                                                    : 10,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .frame(
                            width:
                                UIDevice.isPad
                                ? 125
                                : 72,
                            height:
                                UIDevice.isPad
                                ? 125
                                : 72
                        )
                        .clipShape(Rectangle())

                        // -----------------------------------------
                        // GENERATE BUTTON
                        // -----------------------------------------

                        Button {

                            generateStamp()

                        } label: {

                            HStack(
                                spacing:
                                    UIDevice.isPad
                                    ? 6
                                    : 4
                            ) {

                                if isGeneratingStamp {

                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(
                                            UIDevice.isPad
                                            ? 1.0
                                            : 0.75
                                        )

                                } else {

                                    Image(
                                        systemName:
                                            "wand.and.stars"
                                    )
                                    .font(
                                        .system(
                                            size:
                                                UIDevice.isPad
                                                ? 14
                                                : 10
                                        )
                                    )
                                }

                                Text(
                                    isGeneratingStamp
                                    ? "Membuat..."
                                    : "Buat Prangko"
                                )
                            }
                            .font(
                                .system(
                                    size:
                                        UIDevice.isPad
                                        ? 15
                                        : 10,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .padding(
                                .horizontal,
                                UIDevice.isPad
                                ? 12
                                : 8
                            )
                            .padding(
                                .vertical,
                                UIDevice.isPad
                                ? 8
                                : 4
                            )
                            .background(
                                Capsule()
                                    .fill(
                                        Color(
                                            red: 0.04,
                                            green: 0.12,
                                            blue: 0.45
                                        )
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(
                            message
                                .trimmingCharacters(
                                    in:
                                        .whitespacesAndNewlines
                                )
                                .isEmpty
                            ||
                            isGeneratingStamp
                        )
                    }
                }
                .padding(
                    .top,
                    UIDevice.isPad
                    ? 26
                    : 12
                )
                .padding(
                    .horizontal,
                    UIDevice.isPad
                    ? 30
                    : 12
                )

                Spacer()

                // =================================================
                // MESSAGE
                // =================================================

                TextEditor(
                    text: $message
                )
                .font(
                    .system(
                        size:
                            UIDevice.isPad
                            ? 23
                            : 13,
                        weight: .regular
                    )
                )
                .italic()
                .foregroundStyle(.black)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .overlay(
                    alignment: .topLeading
                ) {

                    if message.isEmpty {

                        Text(
                            "Tulis pesan di sini"
                        )
                        .font(
                            .system(
                                size:
                                    UIDevice.isPad
                                    ? 23
                                    : 13,
                                weight: .regular
                            )
                        )
                        .italic()
                        .foregroundStyle(
                            .gray.opacity(0.7)
                        )
                        .allowsHitTesting(false)
                        .padding(
                            .top,
                            UIDevice.isPad
                            ? 8
                            : 4
                        )
                        .padding(
                            .leading,
                            5
                        )
                    }
                }
                .padding(
                    .horizontal,
                    UIDevice.isPad
                    ? 30
                    : 12
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )

                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }

        // ---------------------------------------------------------
        // POSTCARD HEIGHT
        // ---------------------------------------------------------

        .frame(
            height:
                geometry.size.height
                * (
                    UIDevice.isPad
                    ? 0.64
                    : 0.66
                )
        )
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    UIDevice.isPad
                    ? 16
                    : 12,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.16),
            radius:
                UIDevice.isPad
                ? 10
                : 6,
            x: 0,
            y:
                UIDevice.isPad
                ? 6
                : 3
        )
    }

    // MARK: - Generate Stamp

    @available(iOS 26.0, *)
    private func generateStamp() {

        let cleanedMessage =
            message.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !cleanedMessage.isEmpty else {

            stampError =
                "Tulis pesan terlebih dahulu."

            return
        }

        let model =
            SystemLanguageModel.default

        // MARK: Foundation Models availability

        switch model.availability {

        case .available:
            break

        case .unavailable(
            .appleIntelligenceNotEnabled
        ):

            aiUnavailableMessage = """
            Apple Intelligence belum aktif.

            Aktifkan Apple Intelligence
            melalui Settings → Apple Intelligence & Siri.
            """

            return

        case .unavailable(
            .deviceNotEligible
        ):

            aiUnavailableMessage = """
            Perangkat ini tidak mendukung
            Apple Intelligence.
            """

            return

        case .unavailable(
            .modelNotReady
        ):

            aiUnavailableMessage = """
            Model AI belum siap.

            Tunggu sampai model selesai
            diunduh lalu coba lagi.
            """

            return

        case .unavailable:

            aiUnavailableMessage = """
            Apple Intelligence belum tersedia.
            """

            return
        }

        // MARK: Start generation

        isGeneratingStamp = true
        aiUnavailableMessage = nil
        stampError = nil

        Task { @MainActor in

            do {

                // =====================================
                // STEP 1
                // FOUNDATION MODELS
                // =====================================

                print("================================")
                print("🧠 FOUNDATION MODELS")
                print("================================")

                let promptService =
                    StampPromptService()

                let visualPrompt =
                    try await promptService.generatePrompt(
                        from: cleanedMessage
                    )

                print(
                    "✅ Generated visual prompt:"
                )
                print(visualPrompt)

                // =====================================
                // STEP 2
                // IMAGE CREATOR
                // =====================================

                print("================================")
                print("🎨 IMAGE CREATOR")
                print("================================")

                let imageGenerator =
                    StampImageGenerator()

                let image =
                    try await imageGenerator.generateImage(
                        prompt: visualPrompt
                    )

                // =====================================
                // STEP 3
                // DISPLAY RESULT
                // =====================================

                generatedStamp = image

                print("================================")
                print("✅ STAMP COMPLETE")
                print("================================")

                isGeneratingStamp = false

            } catch {

                print("================================")
                print("❌ STAMP GENERATION FAILED")
                print("================================")

                print(error)
                print(
                    error.localizedDescription
                )

                stampError =
                    error.localizedDescription

                isGeneratingStamp = false
            }
        }
    }

    // MARK: - Send Button

    private var sendButton: some View {

        Button {

            sendPostcard()

        } label: {

            HStack(
                spacing:
                    UIDevice.isPad
                    ? 12
                    : 8
            ) {

                Spacer()

                Text("Kirim Postcard")
                    .font(
                        .system(
                            size:
                                UIDevice.isPad
                                ? 34
                                : 18,
                            weight: .medium
                        )
                    )

                Image(
                    systemName:
                        "paperplane.fill"
                )
                .font(
                    .system(
                        size:
                            UIDevice.isPad
                            ? 30
                            : 16,
                        weight: .medium
                    )
                )

                Spacer()
            }
            .foregroundStyle(.white)
            .frame(
                height:
                    UIDevice.isPad
                    ? 68
                    : 46
            )
            .background(
                Color(
                    red: 0.04,
                    green: 0.12,
                    blue: 0.45
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius:
                        UIDevice.isPad
                        ? 22
                        : 14,
                    style: .continuous
                )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Date

    private var currentDate: String {

        let formatter =
            DateFormatter()

        formatter.locale =
            Locale(
                identifier: "id_ID"
            )

        formatter.dateFormat =
            "dd MMMM yyyy"

        return formatter.string(
            from: Date()
        )
    }

    // MARK: - Actions

    private func openCamera() {

        isCameraPresented = true
    }

    private func helpTapped() {

        print("Help tapped")
    }

    private func sendPostcard() {

        let trimmedMessage =
            message.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedMessage.isEmpty else {
            return
        }

        // Convert captured image to JPEG data

        let imageData =
            selectedImage?.jpegData(
                compressionQuality: 0.85
            )

        // Convert generated stamp to JPEG data

        let stampData =
            generatedStamp?.jpegData(
                compressionQuality: 0.85
            )

        let auth =
            AuthenticationManager.shared

        let senderName =
            auth.displayName.isEmpty
            ? (
                auth.username.isEmpty
                ? "User"
                : "@\(auth.username)"
            )
            : auth.displayName

        let activeGroup =
            auth.activeGroupCode

        let targetRecipient =
            (
                activeGroup != nil
                && !activeGroup!.isEmpty
            )
            ? "Semua Anggota (\(activeGroup!))"
            : recipient

        let postcard =
            Postcard(
                imageData: imageData,
                sender: senderName,
                recipient: targetRecipient,
                date: currentDate,
                message: trimmedMessage,
                stampData: stampData,
                groupCode: activeGroup,
                senderUsername: auth.username,
                senderDisplayName: auth.displayName
            )

        // Save to SwiftData locally

        modelContext.insert(
            postcard
        )

        do {

            try modelContext.save()

            print(
                "✅ Postcard saved locally with ID: \(postcard.id)"
            )

            // Broadcast ke CloudKit group
            // jika terhubung ke grup

            if let groupCode = activeGroup,
               !groupCode.isEmpty {

                Task {

                    do {

                        try await CloudKitGroupService.shared
                            .sendPostcardToGroup(
                                postcard: postcard,
                                imageData: imageData,
                                stampData: stampData
                            )

                        print(
                            "📡 [CloudKit] Postcard berhasil dibroadcast ke seluruh anggota grup \(groupCode)"
                        )

                    } catch {

                        print(
                            "⚠️ [CloudKit] Gagal broadcast postcard ke grup: \(error.localizedDescription)"
                        )
                    }
                }
            }

            selectedTab = 0
            dismiss()

        } catch {

            print(
                "❌ Failed to save postcard: \(error.localizedDescription)"
            )
        }
    }
}

// MARK: - Camera Wrapper

struct CameraViewControllerWrapper:
    UIViewControllerRepresentable {

    let onImageSelected:
        (UIImage) -> Void

    func makeUIViewController(
        context: Context
    ) -> CameraViewController {

        let camera =
            CameraViewController()

        camera.onImageSelected = { image in

            DispatchQueue.main.async {

                onImageSelected(
                    image
                )
            }
        }

        return camera
    }

    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {

        // Nothing needed
    }
}

// MARK: - Preview

#Preview {

    WritePostcardView(
        selectedTab: .constant(0)
    )
}
