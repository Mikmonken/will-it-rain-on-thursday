import Foundation
#if canImport(WebKit)
import WebKit
#endif

@Observable
class WeatherService: ObservableObject {
    private let apiKey = "85ed5a0f3ae71aeebd8eb08ffe1eec4b"
    
    func getThursdayForecast() async throws -> (willRain: Bool, probability: Int, isDaytime: Bool, sunsetTime: String) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=53.2587&lon=-2.1270&appid=\(apiKey)&units=metric"
        
        #if canImport(WebKit)
        // Web-specific implementation
        return try await withCheckedThrowingContinuation { continuation in
            let script = """
                fetch('\(urlString)')
                    .then(response => response.json())
                    .then(data => {
                        return {
                            willRain: data.list[0].pop > 0.5,
                            probability: Math.round(data.list[0].pop * 100),
                            isDaytime: new Date() < new Date(data.city.sunset * 1000),
                            sunsetTime: new Date(data.city.sunset * 1000).toLocaleTimeString()
                        }
                    })
            """
            
            WebView.evaluateJavaScript(script) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
        #else
        // Native iOS implementation remains the same
        // ... existing implementation ...
        #endif
    }
} 