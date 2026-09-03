//
//  DeviceHelper.swift
//  stamppal
//
//  Helper untuk deteksi perangkat (iPhone vs iPad) dan orientasi layar
//  agar tata letak UI proporsional di HP maupun Tablet tanpa merubah bentuknya.
//

import SwiftUI
import UIKit

extension UIDevice {
    /// True jika berjalan di iPad (Tablet)
    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// True jika berjalan di iPhone (HP)
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
