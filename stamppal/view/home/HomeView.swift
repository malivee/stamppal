//
//  HomeView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI
import UIKit

struct HomeView: View {

    // MARK: - Sample Postcards

    private let postcards: [Postcard] = [

        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "01 Agustus 2026",
            message: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """
        ),

        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "28 Juli 2026",
            message: """
            Hello! I hope you are having a wonderful day. I wanted to send you a little postcard to remind you that someone is thinking about you.
            """
        ),

        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "25 Juli 2026",
            message: """
            Greetings from my holiday! The view here is beautiful and I wish you could see it with me.
            """
        ),

        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "20 Juli 2026",
            message: """
            Thank you for always being there. I hope this little postcard makes you smile today.
            """
        ),

        Postcard(
            imageName: "placeholderImage",
            sender: "Andrea Rodriguez",
            date: "18 Juli 2026",
            message: """
            Sending you warm wishes and lots of love. See you soon!
            """
        )
    ]

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            NavigationStack {

                ZStack {

                    // MARK: - Background

                    PostCardBackgroundView()

                    // MARK: - Postcard Stack

                    PostcardStack(
                        postcards: postcards
                    )
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )

                    // MARK: - Help Button

                    VStack {

                        HStack {

                            Spacer()

                            CircleIconButton(
                                icon: "questionmark",
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
    }

    // MARK: - Actions

    private func helpTapped() {

        print("Help tapped")
    }
}

// MARK: - Preview

#Preview {

    HomeView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
