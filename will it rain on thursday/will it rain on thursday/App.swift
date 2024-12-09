import SwiftUI

@main
struct WillItRainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#if canImport(WebKit)
extension WillItRainApp {
    static func main() {
        let app = WillItRainApp()
        WebView(app: app).start()
    }
}
#endif 