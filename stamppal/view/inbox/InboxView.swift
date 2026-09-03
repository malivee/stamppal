//
//  InboxView.swift
//  stamppal
//
//  Created by silalahi klery johansen on 03/09/26.
//

import SwiftUI

struct InboxView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.96, green: 0.96, blue: 0.95)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Kotak Masuk")
                            .font(.system(size: 32, weight: .heavy))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Hari ini")
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                CardView()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, 24)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        SectionHeader(title: "Bulan lalu")
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                CardView()
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
            
            FloatingButton(action: {})
        }
    }
}

struct InboxView_Previews: PreviewProvider {
    static var previews: some View {
        InboxView()
    }
}
