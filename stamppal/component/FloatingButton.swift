//
//  FloatingButton.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//
import SwiftUI

struct FloatingButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Ketuk di Sini Untuk Membuat Kartu")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.28, green: 0.38, blue: 0.55))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
    }
}
#Preview {
    FloatingButton(action: {})
}
