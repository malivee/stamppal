//
//  SectionHeader.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//
import SwiftUI

struct SectionHeader: View {
    var title: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
        }
        .padding(.bottom, 12)
    }
}
#Preview {
    SectionHeader(title: "Hari ini")
}

