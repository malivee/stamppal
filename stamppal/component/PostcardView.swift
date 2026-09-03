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
    private var footerHeight: CGFloat { UIDevice.isPad ? 72 : 46 }

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
                    cornerRadius: UIDevice.isPad ? 14 : 10,
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
                            size: UIDevice.isPad ? 22 : 14,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Text(postcard.date)
                    .font(
                        .system(
                            size: UIDevice.isPad ? 18 : 12,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, UIDevice.isPad ? 28 : 14)
            .frame(
                height: footerHeight
            )
        }
        .background(.white)
        .clipShape(
            RoundedRectangle(
                cornerRadius: UIDevice.isPad ? 14 : 10,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.20),
            radius: UIDevice.isPad ? 12 : 8,
            x: 0,
            y: UIDevice.isPad ? 7 : 4
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
                    spacing: UIDevice.isPad ? 4 : 2
                ) {

                    Text("From : \(postcard.sender)")
                        .font(
                            .system(
                                size: UIDevice.isPad ? 22 : 14,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text(postcard.date)
                        .font(
                            .system(
                                size: UIDevice.isPad ? 18 : 11,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                // MARK: Stamp

                if let stampData = postcard.stampData,
                   let stampImage = UIImage(data: stampData) {

                    Image(uiImage: stampImage)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: UIDevice.isPad ? 105 : 64,
                            height: UIDevice.isPad ? 105 : 64
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
                                    size: UIDevice.isPad ? 17 : 11,
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
                        width: UIDevice.isPad ? 105 : 64,
                        height: UIDevice.isPad ? 105 : 64
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
            .padding(.top, UIDevice.isPad ? 22 : 12)
            .padding(.horizontal, UIDevice.isPad ? 48 : 18)

            Spacer()

            // MARK: Message

            Text(postcard.message)
                .font(
                    .system(
                        size: UIDevice.isPad ? 22 : 13,
                        weight: .regular
                    )
                )
                .italic()
                .foregroundStyle(.black)
                .lineSpacing(UIDevice.isPad ? 5 : 2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, UIDevice.isPad ? 48 : 18)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .minimumScaleFactor(0.8)

            Spacer()

            // MARK: Bottom hint

            HStack {

                Spacer()

                Text("Ketuk untuk melihat gambar")
                    .font(
                        .system(
                            size: UIDevice.isPad ? 17 : 11,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(.blue)
                    .padding(.horizontal, UIDevice.isPad ? 20 : 12)
                    .padding(.vertical, UIDevice.isPad ? 10 : 6)
                    .background(
                        Capsule()
                            .fill(
                                Color.blue.opacity(0.10)
                            )
                    )

                Spacer()
            }
            .padding(.bottom, UIDevice.isPad ? 20 : 10)
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
