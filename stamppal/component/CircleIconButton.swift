//
//  CircleIconButton.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct CircleIconButton: View {
    
    let systemImage: String
    let size: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    init(
        systemImage: String,
        size: CGFloat = 68,
        foregroundColor: Color = .black,
        backgroundColor: Color = .white.opacity(0.45),
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        
        Button {
            action()
        } label: {
            
            Image(systemName: systemImage)
                .font(
                    .system(
                        size: size * 0.38,
                        weight: .medium
                    )
                )
                .foregroundStyle(foregroundColor)
                .frame(
                    width: size,
                    height: size
                )
                .background(
                    Circle()
                        .fill(backgroundColor)
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
