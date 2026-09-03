//
//  SectionHeader.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//

import SwiftUI

struct SectionHeader: View {
    var title: String
    var onChevronTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
            
            if let onChevronTap = onChevronTap {
                Button(action: onChevronTap) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.08, green: 0.12, blue: 0.22))
                }
            }
        }
        .padding(.bottom, 12)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SectionHeader(title: "Hari ini")
        SectionHeader(title: "Kemarin", onChevronTap: {})
    }
    .padding()
}
