//
//  PostcardStack.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct PostcardStack: View {
    
    let postcards: [Postcard]
    
    @State private var currentIndex = 0
    @State private var dragOffset: CGSize = .zero
    
    private let swipeThreshold: CGFloat = 120
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                
                if postcards.isEmpty {
                    
                    emptyState
                    
                } else {
                    
                    ForEach(
                        visibleCards.reversed(),
                        id: \.postcard.id
                    ) { item in
                        
                        postcardCard(
                            item: item,
                            geometry: geometry
                        )
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        }
    }
    
    // MARK: - Visible Cards
    
    private var visibleCards: [
        (
            postcard: Postcard,
            position: Int
        )
    ] {
        
        guard !postcards.isEmpty else {
            return []
        }
        
        let count = min(
            3,
            postcards.count
        )
        
        return (0..<count).map { position in
            
            let index =
                (currentIndex + position)
                % postcards.count
            
            return (
                postcard: postcards[index],
                position: position
            )
        }
    }
    
    // MARK: - Card
    
    @ViewBuilder
    private func postcardCard(
        item: (
            postcard: Postcard,
            position: Int
        ),
        geometry: GeometryProxy
    ) -> some View {
        
        let position = item.position
        
        PostcardView(
            postcard: item.postcard
        )
        .frame(
            width: cardWidth(
                geometry: geometry
            )
        )
        
        // All cards have exactly the same size.
        // Only their position and rotation change.
        
        .offset(
            y: verticalOffset(
                for: position
            )
        )
        
        .rotationEffect(
            rotation(
                for: position
            )
        )
        
        // Drag only the front card.
        
        .offset(
            position == 0
                ? dragOffset
                : .zero
        )
        
        .zIndex(
            Double(
                10 - position
            )
        )
        
        // Only the front card can be swiped.
        
        .gesture(
            position == 0
                ? dragGesture
                : nil
        )
        
        .animation(
            .spring(
                response: 0.45,
                dampingFraction: 0.8
            ),
            value: currentIndex
        )
    }
    
    // MARK: - Card Width
    
    private func cardWidth(
        geometry: GeometryProxy
    ) -> CGFloat {
        
        return min(
            geometry.size.width * 0.52,
            700
        )
    }
    
    // MARK: - Vertical Position
    
    private func verticalOffset(
        for position: Int
    ) -> CGFloat {
        
        switch position {
            
        case 0:
            return -35
            
        case 1:
            return 35
            
        case 2:
            return 105
            
        default:
            return 170
        }
    }
    
    // MARK: - Rotation
    
    private func rotation(
        for position: Int
    ) -> Angle {
        
        switch position {
            
        case 0:
            return .degrees(0)
            
        case 1:
            return .degrees(2)
            
        case 2:
            return .degrees(-2)
            
        default:
            return .degrees(0)
        }
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        
        DragGesture(
            minimumDistance: 10
        )
        .onChanged { value in
            
            dragOffset = value.translation
        }
        .onEnded { value in
            
            let verticalMovement =
                value.translation.height
            
            let horizontalMovement =
                value.translation.width
            
            // Prefer vertical swipe.
            
            if abs(verticalMovement) >
                abs(horizontalMovement) {
                
                if verticalMovement <
                    -swipeThreshold {
                    
                    moveToNext()
                    
                } else if verticalMovement >
                            swipeThreshold {
                    
                    moveToPrevious()
                    
                } else {
                    
                    resetDrag()
                }
                
            } else {
                
                // Horizontal swipe is also supported.
                
                if horizontalMovement <
                    -swipeThreshold {
                    
                    moveToNext()
                    
                } else if horizontalMovement >
                            swipeThreshold {
                    
                    moveToPrevious()
                    
                } else {
                    
                    resetDrag()
                }
            }
        }
    }
    
    // MARK: - Next
    
    private func moveToNext() {
        
        guard postcards.count > 1 else {
            resetDrag()
            return
        }
        
        withAnimation(
            .spring(
                response: 0.45,
                dampingFraction: 0.8
            )
        ) {
            
            currentIndex =
                (currentIndex + 1)
                % postcards.count
            
            dragOffset = .zero
        }
    }
    
    // MARK: - Previous
    
    private func moveToPrevious() {
        
        guard postcards.count > 1 else {
            resetDrag()
            return
        }
        
        withAnimation(
            .spring(
                response: 0.45,
                dampingFraction: 0.8
            )
        ) {
            
            currentIndex =
                (currentIndex - 1 + postcards.count)
                % postcards.count
            
            dragOffset = .zero
        }
    }
    
    // MARK: - Reset
    
    private func resetDrag() {
        
        withAnimation(
            .spring(
                response: 0.4,
                dampingFraction: 0.8
            )
        ) {
            
            dragOffset = .zero
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        
        RoundedRectangle(
            cornerRadius: 20,
            style: .continuous
        )
        .fill(.white)
        .shadow(
            color: .black.opacity(0.15),
            radius: 10,
            y: 5
        )
        .overlay {
            
            VStack(spacing: 12) {
                
                Image(
                    systemName: "envelope"
                )
                .font(
                    .system(size: 45)
                )
                .foregroundStyle(.gray)
                
                Text("Belum ada PostCard")
                    .font(.title2)
                    .foregroundStyle(.gray)
            }
        }
    }
}
