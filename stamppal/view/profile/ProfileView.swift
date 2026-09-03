//
//  ProfileView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct ProfileView: View {

    var body: some View {

        ZStack {

            // MARK: - Background

            LinearGradient(
                colors: [
                    Color(red: 0.78, green: 0.88, blue: 1.00),
                    Color(red: 0.91, green: 0.96, blue: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()


            // MARK: - Content

            VStack(spacing: 0) {

                // MARK: - Title

                HStack {

                    Text("Profile")
                        .font(
                            .system(
                                size: 54,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.black)

                    Spacer()
                }
                .padding(.horizontal, 80)
                .padding(.top, 55)


                Spacer()


                // MARK: - Profile Information

                VStack(spacing: 14) {

                    // Profile Icon

                    Image(systemName: "person.fill")
                        .font(
                            .system(
                                size: 52,
                                weight: .medium
                            )
                        )
                        .foregroundStyle(.black)
                        .frame(
                            width: 100,
                            height: 100
                        )
                        .background(
                            Circle()
                                .fill(
                                    .white.opacity(0.55)
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(
                                    .white.opacity(0.8),
                                    lineWidth: 1
                                )
                        )


                    // Name

                    Text("Noorfy")
                        .font(
                            .system(
                                size: 34,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.black)


                    // Email

                    Text("noorfy@gmail.com")
                        .font(
                            .system(
                                size: 26,
                                weight: .regular
                            )
                        )
                        .foregroundStyle(
                            .gray
                        )
                }


                Spacer()


                // MARK: - Profile Options

                VStack(spacing: 0) {

                    ProfileRow(
                        title: "Tambahkan orang"
                    ) {
                        print("Tambahkan orang tapped")
                    }

                    Divider()
                        .padding(.horizontal, 24)

                    ProfileRow(
                        title: "Daftar keluarga"
                    ) {
                        print("Daftar keluarga tapped")
                    }
                }
                .background(
                    RoundedRectangle(
                        cornerRadius: 30,
                        style: .continuous
                    )
                    .fill(.white)
                )
                .padding(.horizontal, 170)


                Spacer()
                    .frame(height: 100)
            }
        }
        .ignoresSafeArea()
    }
}


// MARK: - Profile Row

struct ProfileRow: View {

    let title: String
    let action: () -> Void

    var body: some View {

        Button {
            action()
        } label: {

            HStack {

                Text(title)
                    .font(
                        .system(
                            size: 22,
                            weight: .regular
                        )
                    )
                    .foregroundStyle(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )
                    .foregroundStyle(
                        .gray.opacity(0.6)
                    )
            }
            .padding(.horizontal, 28)
            .frame(height: 70)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


#Preview {

    ProfileView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
