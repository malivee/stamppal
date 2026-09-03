//
//  HomeView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

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
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                // MARK: - Background
                
                background
                
                // MARK: - Postcard Stack
                
                PostcardStack(
                    postcards: postcards
                )
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                

                
                // MARK: - Top Buttons
                
                VStack {
                    
                    HStack {
                        
                        CircleIconButton(
                            systemImage: "archivebox.fill",
                            size: 68
                        ) {
                            archiveTapped()
                        }
                        
                        Spacer()
                        
                        CircleIconButton(
                            systemImage: "questionmark",
                            size: 68
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
                
                // MARK: - Compose Button
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                        
                        Spacer()
                        
                        Button {
                            composeTapped()
                        } label: {
                            
                            Image(
                                systemName: "pencil"
                            )
                            .font(
                                .system(
                                    size: 28,
                                    weight: .medium
                                )
                            )
                            .foregroundStyle(.white)
                            .frame(
                                width: 82,
                                height: 82
                            )
                            .background(
                                Circle()
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
                        .shadow(
                            color: .black.opacity(0.20),
                            radius: 9,
                            x: 0,
                            y: 5
                        )
                    }
                    .padding(
                        .horizontal,
                        50
                    )
                    .padding(
                        .bottom,
                        25
                    )
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Background
    
    private var background: some View {
        
        ZStack {
            
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
                            red: 0.88,
                            green: 0.94,
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
            
            VStack {
                
                Spacer()
                
                Rectangle()
                    .fill(.white)
                    .frame(
                        height: 150
                    )
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Actions
    
    private func archiveTapped() {
        print("Archive tapped")
    }
    
    private func helpTapped() {
        print("Help tapped")
    }
    
    private func composeTapped() {
        print("Create PostCard tapped")
    }
}

#Preview {
    HomeView()
}
