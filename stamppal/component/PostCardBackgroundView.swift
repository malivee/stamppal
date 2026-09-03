//
//  PostCardBackgroundView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct PostCardBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sky Blue Gradient Top Background
                LinearGradient(
                    colors: [
                        Color(red: 0.82, green: 0.90, blue: 0.98),
                        Color(red: 0.65, green: 0.78, blue: 0.92)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // White Curved Hill Layer with Drop Shadow
                WhiteWaveShape()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: -4)
            }
        }
        .ignoresSafeArea()
    }
}

struct WhiteWaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        let startY = height * 0.78
        path.move(to: CGPoint(x: 0, y: startY))
        
        let controlPoint = CGPoint(x: width * 0.5, y: height * 0.22)
        let endPoint = CGPoint(x: width, y: startY)
        
        path.addQuadCurve(to: endPoint, control: controlPoint)
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}
#Preview {
    PostCardBackgroundView()
}
