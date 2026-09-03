//
//  CardView.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//
import SwiftUI

struct CardView: View {
    var title: String?
    var date: String?
    var badgeText: String?
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(Color(red: 0.83, green: 0.86, blue: 0.99))
                    .frame(width: 240)
                    .cornerRadius(4)
                    .padding(.bottom, 12)
                
                Text(title ?? "mawar itu merah violet itu biru,nona manis apa kabarmu")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .padding(.bottom, 16)
                
                Spacer()
                
                Text(date ?? "dd mm yyyy")
                    .font(.system(size: 14).italic())
                    .foregroundColor(.black)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .frame(width: 240, height: 260)
            
            if let badgeText = badgeText {
                Text(badgeText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(Color(red: 0.23, green: 0.62, blue: 1.0))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .offset(x: -16, y: 40)
            }
        }
    }
}
#Preview {
    CardView()
}
