import SwiftUI
import UIKit

struct WritePostcardView: View {

    // MARK: - Image

    @State private var selectedImage: UIImage?

    // MARK: - Text

    @State private var recipient = "Andrea Rodriguez"
    @State private var message = ""

    // MARK: - Navigation

    @Environment(\.dismiss) private var dismiss

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

        // MARK: Camera Presentation

        .fullScreenCover(
            isPresented: $isCameraPresented
        ) {

            CameraViewControllerWrapper { image in

                // Receive captured image
                selectedImage = image

                // Close camera
                isCameraPresented = false
            }
            .ignoresSafeArea()
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

            // Home Button

            Button {

                dismiss()

            } label: {

                Image(systemName: "house.fill")
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

            // Title

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

            // Help Button

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

                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()

                } else {

                    Image("placeholderImage")
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

                    // MARK: Stamp

                    ZStack {

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
                    .frame(
                        width: 125,
                        height: 125
                    )
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

        let formatter = DateFormatter()

        formatter.locale =
            Locale(identifier: "id_ID")

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

                onImageSelected(image)
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
