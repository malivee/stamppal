//
//  HomeView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI

struct HomeView: View {

    var body: some View {

        NavigationStack {

            VStack {
                Text("Ada kiriman postcard baru dari \(Text("User lain").font(.title.bold()))")
                    .font(.title)
                
                ZStack(alignment: .topLeading) {
                    Image("placeholderImage")
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(1.5, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    
                    Button {
                        
                    } label: {
                        Text("Ketuk gambar untuk buka PostCard")
                            .font(.title.bold())
                            .foregroundStyle(.blue)
                            .padding()
                            .background(.blue.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 26)
                    .padding(.leading, 80)
                    .aspectRatio(1.5, contentMode: .fit)

                }
                
                Text("2 dari 10 PostCard belum dibaca")
                    .font(.title2.bold())
                    
                Button {
                    
                } label: {
                    Text("Ketuk disini untuk melihat seluruh")
                }

                Spacer()
            }

            .navigationTitle("Hello User")
            .toolbarTitleDisplayMode(.inlineLarge)

            .toolbar {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Label("Account", systemImage: "person.fill")
                        .labelStyle(.iconOnly)
                })
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
