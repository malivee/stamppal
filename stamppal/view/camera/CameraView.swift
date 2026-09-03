//
//  CameraView.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//


import SwiftUI

struct CameraView: UIViewControllerRepresentable {

    func makeUIViewController(
        context: Context
    ) -> CameraViewController {

        let controller = CameraViewController()

        return controller
    }

    func updateUIViewController(
        _ uiViewController: CameraViewController,
        context: Context
    ) {
    }
}
