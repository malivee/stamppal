//
//  PostcardView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI
import UIKit

struct PostcardView: View {

    let postcard: Postcard

    @State private var isFlipped = false

    // The image determines the postcard's main size.
    private let imageAspectRatio: CGFloat = 1.2
    private let footerHeight: CGFloat = 72

    var body: some View {

        GeometryReader { geometry in

            let imageHeight =
                geometry.size.width / imageAspectRatio

            let cardHeight =
                imageHeight + footerHeight

            ZStack {

                // MARK: FRONT

                postcardFront(
                    imageHeight: imageHeight
                )
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )

                // MARK: BACK

                postcardBack(
                    cardHeight: cardHeight
                )
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.5
                )
            }
            .frame(
                width: geometry.size.width,
                height: cardHeight
            )
            .contentShape(
                RoundedRectangle(
                    cornerRadius: 14,
                    style: .continuous
                )
            )
            .onTapGesture {

                withAnimation(
                    .easeInOut(duration: 0.7)
                ) {
                    isFlipped.toggle()
                }
            }
        }
        .aspectRatio(
            imageAspectRatio,
            contentMode: .fit
        )
    }

    // MARK: - Front

    private func postcardFront(
        imageHeight: CGFloat
    ) -> some View {

        VStack(spacing: 0) {

            Group {

                if let imageData = postcard.imageData,
                   let uiImage = UIImage(data: imageData) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()

                } else if let imageName = postcard.imageName {

                    Image(imageName)
                        .resizable()
                        .scaledToFill()

                } else {

                    Image("imagePlaceholder")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(
                maxWidth: .infinity
            )
            .frame(
                height: imageHeight
            )
            .clipped()

            HStack(alignment: .center) {

                Text("From : \(postcard.sender)")
                    .font(
                        .system(
                            size: 22,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .lineLimit(1)

                Spacer()

                Text(postcard.date)
                    .font(
                        .system(
                            size: 18,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 28)
            .frame(
                height: footerHeight
            )
        }
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.20),
            radius: 12,
            x: 0,
            y: 7
        )
    }

    // MARK: - Back

    private func postcardBack(
        cardHeight: CGFloat
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            // MARK: Top section

            HStack(
                alignment: .top
            ) {

                // Sender information
                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text("From : \(postcard.sender)")
                        .font(
                            .system(
                                size: 22,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.black)

                    Text(postcard.date)
                        .font(
                            .system(
                                size: 18,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(.gray)
                }

                Spacer()

                // MARK: Stamp

                if let stampData = postcard.stampData,
                   let stampImage = UIImage(data: stampData) {

                    Image(uiImage: stampImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: 105,
                            height: 105
                        )
                        .clipped()
                        .overlay(
                            Rectangle()
                                .stroke(
                                    .black.opacity(0.12),
                                    lineWidth: 1
                                )
                        )

                } else {

                    // Placeholder when there is no stamp
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
                                    size: 17,
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
                        width: 105,
                        height: 105
                    )
                    .overlay(
                        Rectangle()
                            .stroke(
                                .black.opacity(0.12),
                                lineWidth: 1
                            )
                    )
                }
            }
            .padding(.top, 22)
            .padding(.horizontal, 48)

            Spacer()

            // MARK: Message

            Text(postcard.message)
                .font(
                    .system(
                        size: 22,
                        weight: .regular
                    )
                )
                .italic()
                .foregroundStyle(.black)
                .lineSpacing(5)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 48)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Spacer()

            // MARK: Bottom hint

            HStack {

                Spacer()

                Text("Ketuk untuk melihat gambar")
                    .font(
                        .system(
                            size: 17,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(
                                Color.blue.opacity(0.10)
                            )
                    )

                Spacer()
            }
            .padding(.bottom, 20)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: cardHeight
        )
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.20),
            radius: 12,
            x: 0,
            y: 7
        )
    }
}

#Preview {

    PostcardView(
        postcard: Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "01 Agustus 2026",
            message: """
            Lorem ipsum dolor sit amet,
            consectetur adipiscing elit.
            Sed do eiusmod tempor incididunt
            ut labore et dolore magna aliqua.
            """
        )
    )
    .frame(width: 600)
    .padding()
}
