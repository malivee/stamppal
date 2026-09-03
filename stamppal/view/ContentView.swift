import SwiftUI

struct ContentView: View {
    @State private var internalTab: Int = 0
    private var externalTab: Binding<Int>?
    
    init(selectedTab: Binding<Int>? = nil) {
        self.externalTab = selectedTab
    }
    
    private var activeTabBinding: Binding<Int> {
        externalTab ?? $internalTab
    }

    var body: some View {
        TabView(selection: activeTabBinding) {

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
            CameraView()
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
    ContentView()
        .previewInterfaceOrientation(
            .landscapeLeft
        )
}
