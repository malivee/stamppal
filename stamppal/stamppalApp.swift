//
//  stamppalApp.swift
//  stamppal
//
//  Created by Muhammad Alief Rahman Fardillah on 03/09/26.
//

import SwiftUI
import SwiftData

@main
struct stamppalApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: Postcard.self
        )
    }
}
