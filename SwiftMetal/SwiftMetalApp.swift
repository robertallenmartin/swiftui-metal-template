
import SwiftUI

@main
struct SwiftMetalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        // Begin timer when app starts.
        DeltaTimer.updateTime()
    }
}
