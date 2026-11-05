import SwiftUI

@main
struct CurrencyToTextApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 620, minHeight: 560)
        }
        .windowResizability(.contentSize)
    }
}
