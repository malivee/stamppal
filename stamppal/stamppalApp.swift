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

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var selectedTab: Int = 0

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView(selectedTab: $selectedTab)
                } else {
                    OnboardingView(
                        onJoin: {
                            selectedTab = 0
                            withAnimation(.easeInOut(duration: 0.35)) {
                                hasCompletedOnboarding = true
                            }
                        },
                        onCreate: {
                            selectedTab = 0
                            withAnimation(.easeInOut(duration: 0.35)) {
                                hasCompletedOnboarding = true
                            }
                        }
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: hasCompletedOnboarding)
        }
        .modelContainer(
            for: Postcard.self
        )
    }
}
