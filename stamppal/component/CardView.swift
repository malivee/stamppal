//
//  CardView.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//

import SwiftUI

struct CardView: View {
    var personName: String = "Andrea Rodriguez"
    var date: String = "01 August 2026"
    var prefix: String = "From"
    var imageName: String? = nil
    var customImage: Image? = nil
    
    // Convenience init with isIncoming flag
    init(
        personName: String = "Andrea Rodriguez",
        date: String = "01 August 2026",
        isIncoming: Bool = true,
        imageName: String? = nil,
        customImage: Image? = nil
    ) {
        self.personName = personName
        self.date = date
        self.prefix = isIncoming ? "From" : "Kepada"
        self.imageName = imageName
        self.customImage = customImage
    }
    
    // Custom prefix init
    init(
        prefix: String,
        personName: String,
        date: String,
        imageName: String? = nil,
        customImage: Image? = nil
    ) {
        self.prefix = prefix
        self.personName = personName
        self.date = date
        self.imageName = imageName
        self.customImage = customImage
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Image / Image Holder Area
            imageHolderView
                .padding(10)
            
            // MARK: - Footer Info (Sender/Recipient & Date)
            HStack(alignment: .center) {
                Text("\(prefix) : \(personName)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.12, green: 0.14, blue: 0.18))
                    .lineLimit(1)
                
                Spacer(minLength: 8)
                
                Text(date)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(Color(red: 0.50, green: 0.53, blue: 0.58))
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.top, 2)
            .padding(.bottom, 14)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
    
    // MARK: - Image Holder Component
    @ViewBuilder
    private var imageHolderView: some View {
        if let customImage = customImage {
            customImage
                .resizable()
                .aspectRatio(1.6, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else if let imageName = imageName, !imageName.isEmpty {
            Image(imageName)
                .resizable()
                .aspectRatio(1.6, contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        } else {
            // Clean, elegant Image Holder placeholder
            ZStack {
                Color(red: 0.92, green: 0.94, blue: 0.96)
                
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color(red: 0.58, green: 0.63, blue: 0.70))
                    
                    Text("Image Holder")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.58, green: 0.63, blue: 0.70))
                }
            }
            .aspectRatio(1.6, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

#Preview("Masuk Mode") {
    ZStack {
        Color(red: 0.88, green: 0.94, blue: 1.0)
            .ignoresSafeArea()
        CardView(
            personName: "Andrea Rodriguez",
            date: "01 August 2026",
            isIncoming: true
        )
        .frame(width: 320)
        .padding()
    }
}

#Preview("Keluar Mode") {
    ZStack {
        Color(red: 0.88, green: 0.94, blue: 1.0)
            .ignoresSafeArea()
        CardView(
            personName: "Alverz Belinza",
            date: "01 August 2026",
            isIncoming: false
        )
        .frame(width: 320)
        .padding()
    }
}
