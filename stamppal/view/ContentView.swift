import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {

            // MARK: - Home
            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "house.fill"
                    )
                }

            // MARK: - Camera
            CameraView()
                .tabItem {
                    Label(
                        "Create",
                        systemImage: "pencil"
                    )
                }


            // MARK: - Inbox
            InboxView()
                .tabItem {
                    Label(
                        "Inbox",
                        systemImage: "tray.fill"
                    )
                }

            // MARK: - Profile
            ProfileView()
                .tabItem {
                    Label(
                        "Profile",
                        systemImage: "person.fill"
                    )
                }
        }
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
