//
//  ModeToggle.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//

import SwiftUI

enum GalleryMode: String, CaseIterable {
    case masuk = "Masuk"
    case keluar = "Keluar"
}

struct ModeToggle: View {
    @Binding var currentMode: GalleryMode
    
    var body: some View {
        HStack(spacing: 0) {
            segmentButton(
                mode: .masuk,
                icon: "tray.and.arrow.down.fill"
            )
            
            segmentButton(
                mode: .keluar,
                icon: "tray.and.arrow.up.fill"
            )
        }
        .background(Color.white.opacity(0.3))
        .overlay(
            Capsule()
                .stroke(Color(red: 0.08, green: 0.14, blue: 0.32).opacity(0.18), lineWidth: 1)
        )
        .clipShape(Capsule())
    }
    
    @ViewBuilder
    private func segmentButton(mode: GalleryMode, icon: String) -> some View {
        let isSelected = currentMode == mode
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentMode = mode
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                
                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color(red: 0.08, green: 0.14, blue: 0.32).opacity(0.75))
            .padding(.horizontal, 22)
            .padding(.vertical, 10)
            .background(
                isSelected ? Color(red: 0.06, green: 0.14, blue: 0.36) : Color.clear
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color(red: 0.88, green: 0.94, blue: 1.0)
            .ignoresSafeArea()
        
        StatefulPreviewWrapper(GalleryMode.masuk) { modeBinding in
            ModeToggle(currentMode: modeBinding)
        }
    }
}

private struct StatefulPreviewWrapper<T, Content: View>: View {
    @State var state: T
    var content: (Binding<T>) -> Content
    
    init(_ state: T, @ViewBuilder content: @escaping (Binding<T>) -> Content) {
        self._state = State(initialValue: state)
        self.content = content
    }
    
    var body: some View {
        content($state)
    }
}
