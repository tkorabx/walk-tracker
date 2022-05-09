import SwiftUI

@main
struct AppLauncher {

    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            WalkTrackerApp.main()
        } else {
            TestApp.main()
        }
    }
}

// Blocks app from being launched during Unit Tests
struct TestApp: App {

    var body: some Scene {
        WindowGroup {
            Text("Unit Testing...")
        }
    }
}

// Main App
struct WalkTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ListView()
            }
        }
    }
}
