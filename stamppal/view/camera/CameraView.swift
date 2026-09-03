//
//  CameraView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI
import UIKit

struct CameraView: View {

    // MARK: - Navigation

    @State private var capturedImage: UIImage?
    @State private var showWritePostcard = false
    @Binding var selectedTab: Int

    var body: some View {

        NavigationStack {

            CameraViewControllerWrapper { image in

                // Receive the captured image
                capturedImage = image

                // Open postcard writing page
                showWritePostcard = true
            }
            .ignoresSafeArea()

            // MARK: - Write Postcard

            .navigationDestination(
                isPresented: $showWritePostcard
            ) {

                WritePostcardView(
                    image: capturedImage
                    ,selectedTab: $selectedTab
                )
                .navigationBarBackButtonHidden()
                .toolbar(.hidden, for: .tabBar)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
}

#Preview {

    CameraView(selectedTab: .constant(0))
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
