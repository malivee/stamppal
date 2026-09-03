import SwiftUI
import UIKit
import FoundationModels

struct WritePostcardView: View {

    // MARK: - Image

    @State private var selectedImage: UIImage?

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

    init(image: UIImage? = nil) {

        _selectedImage = State(
            initialValue: image
        )
    }

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            ZStack {

                background

                VStack(spacing: 0) {

                    // MARK: Header

                    header

                    Spacer(minLength: 25)

                    // MARK: Postcard

                    postcard(
                        geometry: geometry
                    )

                    Spacer(minLength: 35)

                    // MARK: Send Button

                    sendButton

                    Spacer(minLength: 25)
                }
                .padding(.horizontal, 42)
            }
        }

        .ignoresSafeArea()

        .navigationBarBackButtonHidden()

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

            Button {

                dismiss()

            } label: {

                Image(
                    systemName: "house.fill"
                )
                .font(
                    .system(
                        size: 30,
                        weight: .medium
                    )
                )
                .foregroundStyle(.black)
                .frame(
                    width: 68,
                    height: 68
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

            VStack(spacing: 2) {

                Text("Tulis Kartu Pos")
                    .font(
                        .system(
                            size: 40,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.black)

                Text(
                    "Tulis pesan bermakna untuk orang tersayang"
                )
                .font(
                    .system(
                        size: 24,
                        weight: .medium
                    )
                )
                .foregroundStyle(.gray)
            }

            Spacer()

            Button {

                helpTapped()

            } label: {

                Text("?")
                    .font(
                        .system(
                            size: 30,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width: 68,
                        height: 68
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

        HStack(spacing: 0) {

            // MARK: Image

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
                width: geometry.size.width * 0.39
            )
            .frame(
                maxHeight: .infinity
            )
            .clipped()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )

            // MARK: Camera Button

            .overlay(
                alignment: .bottom
            ) {

                Button {

                    openCamera()

                } label: {

                    Image(
                        systemName: "camera.fill"
                    )
                    .font(
                        .system(
                            size: 25,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width: 82,
                        height: 82
                    )
                    .background(
                        Circle()
                            .fill(.white)
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                Color.gray.opacity(0.35),
                                lineWidth: 4
                            )
                    )
                }
                .buttonStyle(.plain)
                .offset(y: 5)
            }

            // MARK: Writing Area

            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                // MARK: Recipient / Date / Stamp

                HStack {

                    VStack(
                        alignment: .leading,
                        spacing: 4
                    ) {

                        Text(
                            "Kepada : \(recipient)"
                        )
                        .font(
                            .system(
                                size: 25,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.black)

                        Text(currentDate)
                            .font(
                                .system(
                                    size: 20,
                                    weight: .regular
                                )
                            )
                            .foregroundStyle(.gray)
                    }

                    Spacer()

                    // MARK: AI Stamp

                    VStack(spacing: 8) {

                        ZStack {

                            if let generatedStamp {

                                Image(
                                    uiImage: generatedStamp
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
                                            size: 23,
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

                            // Loading overlay

                            if isGeneratingStamp {

                                Rectangle()
                                    .fill(
                                        .black.opacity(0.35)
                                    )

                                VStack(spacing: 8) {

                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.2)

                                    Text("Membuat...")
                                        .font(
                                            .system(
                                                size: 14,
                                                weight: .medium
                                            )
                                        )
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .frame(
                            width: 125,
                            height: 125
                        )
                        .clipShape(Rectangle())

                        Button {

                            generateStamp()

                        } label: {

                            HStack(spacing: 6) {

                                if isGeneratingStamp {

                                    ProgressView()
                                        .tint(.white)

                                } else {

                                    Image(
                                        systemName:
                                            "wand.and.stars"
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
                                    size: 15,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .padding(
                                .horizontal,
                                12
                            )
                            .padding(
                                .vertical,
                                8
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
                                    in: .whitespacesAndNewlines
                                )
                                .isEmpty
                            ||
                            isGeneratingStamp
                        )
                    }
                }
                .padding(
                    .top,
                    32
                )
                .padding(
                    .horizontal,
                    30
                )

                Spacer()

                // MARK: Message

                TextEditor(
                    text: $message
                )
                .font(
                    .system(
                        size: 23,
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
                            "Type here to write a message"
                        )
                        .font(
                            .system(
                                size: 23,
                                weight: .regular
                            )
                        )
                        .italic()
                        .foregroundStyle(.black)
                        .allowsHitTesting(false)
                        .padding(.top, 8)
                        .padding(.leading, 5)
                    }
                }
                .padding(
                    .horizontal,
                    30
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
        .frame(
            height: geometry.size.height * 0.60
        )
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.16),
            radius: 10,
            x: 0,
            y: 6
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

                print("✅ Generated visual prompt:")
                print(visualPrompt)

                // =====================================
                // STEP 2
                // IMAGE CREATOR
                //
                // NO PLAYGROUND UI
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
                print(error.localizedDescription)

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

            HStack(spacing: 12) {

                Spacer()

                Text("Kirim Kartu Pos")
                    .font(
                        .system(
                            size: 34,
                            weight: .medium
                        )
                    )

                Image(
                    systemName: "paperplane.fill"
                )
                .font(
                    .system(
                        size: 30,
                        weight: .medium
                    )
                )

                Spacer()
            }
            .foregroundStyle(.white)
            .frame(
                height: 68
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
                    cornerRadius: 22,
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

        print(
            "Sending postcard:",
            message
        )

        print(
            "Stamp exists:",
            generatedStamp != nil
        )
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

    WritePostcardView()
}
