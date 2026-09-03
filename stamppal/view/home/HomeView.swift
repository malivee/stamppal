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
        .padding(280)
        .background {
            Color.white
        }
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 40)
        .shadow(radius: 20)
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
