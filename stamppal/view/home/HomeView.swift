//
//  HomeView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct HomeView: View {

    @State private var isFlipped = false

    var body: some View {

        NavigationStack {

            VStack {

                Text(
                    "Ada kiriman postcard baru dari \(Text("User lain").font(.title.bold()))"
                )
                .font(.title)

                
                ZStack {
                    ZStack(alignment: .topLeading) {
                        
                        Image("placeholderImage")
                            .resizable()
                            .scaledToFill()
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity
                            )
                            .clipped()
                            .clipShape(
                                RoundedRectangle(cornerRadius: 30)
                            )

                        // Instruction button
                        Button {
                            withAnimation(.easeInOut(duration: 0.7)) {
                                isFlipped = true
                            }
                        } label: {

                            Text("Ketuk gambar untuk buka PostCard")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .padding()
                                .background(
                                    .blue.opacity(0.7)
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .padding(.top, 26)
                        .padding(.leading, 120)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )


                    ZStack(alignment: .topLeading) {

                        RoundedRectangle(cornerRadius: 30)
                            .fill(.white)

                        HStack(spacing: 0) {

                            VStack(alignment: .leading, spacing: 18) {

                                Text("Dear friend,")
                                    .font(.title2)

                                Spacer()
                                    .frame(height: 20)

                                Text("""
                                This is the area where you write
                                a message to the recipient of
                                the card. Be sincere and keep it
                                brief.
                                """)
                                .font(.title3)
                                .foregroundStyle(.gray)

                                Spacer()
                            }
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .leading
                            )
                            .padding(.leading, 50)
                            .padding(.top, 45)
                            .padding(.bottom, 35)


                            Rectangle()
                                .fill(.black.opacity(0.7))
                                .frame(width: 2)
                                .padding(.vertical, 45)


                            VStack(spacing: 15) {

                                HStack {

                                    Spacer()

                                    Text("""
                                    PLACE
                                    STAMP
                                    HERE
                                    """)
                                    .font(.caption.bold())
                                    .multilineTextAlignment(.center)
                                    .frame(
                                        width: 80,
                                        height: 80
                                    )
                                    .overlay(
                                        Rectangle()
                                            .stroke(
                                                .black,
                                                lineWidth: 2
                                            )
                                    )
                                }

                                Spacer()

                                Text("Jane Dear Friend")
                                    .font(.title2)

                                Rectangle()
                                    .fill(.black)
                                    .frame(height: 1)

                                Text("456 Nice Street")
                                    .font(.title3)

                                Rectangle()
                                    .fill(.black)
                                    .frame(height: 1)

                                Text("Nice Town, Great State")
                                    .font(.title3)

                                Spacer()
                            }
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity
                            )
                            .padding(.horizontal, 40)
                            .padding(.top, 25)
                            .padding(.bottom, 35)
                        }



                        Text("Ketuk di sini untuk lihat gambar")
                            .font(.title2)
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        .blue.opacity(0.15)
                                    )
                            )
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .bottomTrailing
                            )
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(
                        .degrees(isFlipped ? 0 : -180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                }
                .aspectRatio(1.5, contentMode: .fit)
                .onTapGesture {

                    withAnimation(
                        .easeInOut(duration: 0.7)
                    ) {
                        isFlipped.toggle()
                    }
                }
                .aspectRatio(1.5, contentMode: .fit)
                .onTapGesture {
                    withAnimation(
                        .easeInOut(duration: 0.7)
                    ) {
                        isFlipped.toggle()
                    }
                }

                Text("2 dari 10 PostCard belum dibaca")
                    .font(.title2.bold())


                FloatingButton(action: {
                })

                Spacer()
            }


            .navigationTitle("Hello User")
            .toolbarTitleDisplayMode(.inlineLarge)

            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Label(
                        "Account",
                        systemImage: "person.fill"
                    )
                    .labelStyle(.iconOnly)
                }
            }
        }
        .padding()
    }
}


#Preview {
    HomeView()
}
