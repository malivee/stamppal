import SwiftUI

struct ContentView: View {

    @Binding var selectedTab: Int

    var body: some View {

        TabView(selection: $selectedTab) {

            // MARK: - Home
            HomeView()
                .tabItem {
                    Label(
                        "Home",
                        systemImage: "house.fill"
                    )
                }
                .tag(0)

            // MARK: - Camera
            CameraView(selectedTab: $selectedTab)
                .tabItem {
                    Label(
                        "Create",
                        systemImage: "pencil"
                    )
                }
                .tag(1)

            // MARK: - Inbox
            InboxView()
                .tabItem {
                    Label(
                        "Inbox",
                        systemImage: "tray.fill"
                    )
                }
                .tag(2)

            // MARK: - Profile
            ProfileView()
                .tabItem {
                    Label(
                        "Profile",
                        systemImage: "person.fill"
                    )
                }
                .tag(3)
        }
    }
}

#Preview {
    ContentView(selectedTab: .constant(0))
        .previewInterfaceOrientation(.landscapeLeft)
}
