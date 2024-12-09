//
//  ContentView.swift
//  will it rain on thursday
//
//  Created by Mike Gaskell on 09/12/2024.
//

import SwiftUI

struct TimelineView: View {
    let timeline: [TimelineData]
    
    private func sunPath(in geometry: GeometryProxy, for type: SunType) -> Path {
        var path = Path()
        let height = geometry.size.height
        let width = geometry.size.width
        
        // Create an arc for sunrise/sunset
        let controlPoint = CGPoint(x: width/2, y: type == .sunrise ? height - 40 : height - 10)
        let startPoint = CGPoint(x: 0, y: height - 20)
        let endPoint = CGPoint(x: width, y: height - 20)
        
        path.move(to: startPoint)
        path.addQuadCurve(to: endPoint, control: controlPoint)
        
        return path
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("12-Hour Timeline")
                .font(.headline)
                .padding(.bottom, 4)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background grid
                    Path { path in
                        for i in 0...12 {
                            let x = CGFloat(i) * geometry.size.width / 12
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                        }
                    }
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    
                    // Rain probability line
                    if timeline.count > 1 {
                        Path { path in
                            let points = timeline.enumerated().map { index, data -> CGPoint in
                                let x = CGFloat(index) * geometry.size.width / CGFloat(timeline.count - 1)
                                let y = geometry.size.height * (1 - CGFloat(data.probability) / 100)
                                return CGPoint(x: x, y: y)
                            }
                            
                            path.move(to: points[0])
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                        .stroke(Color.blue, lineWidth: 2)
                    }
                    
                    // Sun path indicators
                    ForEach(timeline.indices, id: \.self) { index in
                        if timeline[index].isSunrise {
                            sunPath(in: geometry, for: .sunrise)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                            Image(systemName: "sunrise.fill")
                                .foregroundStyle(.orange)
                                .position(x: CGFloat(index) * geometry.size.width / CGFloat(timeline.count - 1),
                                        y: geometry.size.height - 20)
                        }
                        if timeline[index].isSunset {
                            sunPath(in: geometry, for: .sunset)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 2)
                            Image(systemName: "sunset.fill")
                                .foregroundStyle(.orange)
                                .position(x: CGFloat(index) * geometry.size.width / CGFloat(timeline.count - 1),
                                        y: geometry.size.height - 20)
                        }
                    }
                }
            }
            .frame(height: 100)
            
            // Time labels with sun indicators
            HStack {
                ForEach(timeline.indices, id: \.self) { index in
                    if index % 2 == 0 {
                        VStack(spacing: 2) {
                            Text(timeString(from: timeline[index].time))
                                .font(.caption2)
                            if timeline[index].isSunrise {
                                Image(systemName: "sunrise.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                            if timeline[index].isSunset {
                                Image(systemName: "sunset.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private enum SunType {
        case sunrise, sunset
    }
}

struct ContentView: View {
    @State private var willRain: Bool?
    @State private var probability: Int?
    @State private var timeline: [TimelineData] = []
    @State private var isDaytime: Bool = true
    @State private var isLoading = false
    @State private var error: Error?
    @State private var sunsetTime: String = ""
    @State private var sunsetStatus: String = ""
    @State private var moonPhase: Double = 0.0
    @State private var hannoDelay: Int = 0
    @State private var helmetTilt: Int = 0
    
    @StateObject private var weatherService = WeatherService()
    
    private func weatherIcon() -> String {
        if willRain == true {
            if isDaytime {
                return "cloud.sun.rain.fill"
            } else {
                // Moon with rain
                return "cloud.moon.rain.fill"
            }
        } else {
            if isDaytime {
                return "sun.max.fill"
            } else {
                // Different moon phases
                switch moonPhase {
                case 0.0...0.125: return "moon.fill"           // New moon
                case 0.125...0.25: return "moon.stars.fill"    // Waxing crescent
                case 0.25...0.375: return "moonphase.first.quarter.fill"
                case 0.375...0.625: return "moonphase.full.fill"
                case 0.625...0.75: return "moonphase.last.quarter.fill"
                case 0.75...0.875: return "moon.stars.fill"    // Waning crescent
                default: return "moon.fill"                    // New moon
                }
            }
        }
    }
    
    private func weatherColor() -> Color {
        if willRain == true {
            return .blue
        } else {
            return isDaytime ? .yellow : .indigo
        }
    }
    
    private func backgroundColors() -> [Color] {
        if isDaytime {
            return [.blue.opacity(0.3), .cyan.opacity(0.2)] // Daylight colors
        } else {
            return [.indigo.opacity(0.4), .black.opacity(0.3)] // After sunset colors
        }
    }
    
    private func helmetIcon(tilt: Double) -> some View {
        ZStack {
            // Helmet shape
            Path { path in
                path.move(to: CGPoint(x: 20, y: 40))
                path.addQuadCurve(
                    to: CGPoint(x: 60, y: 40),
                    control: CGPoint(x: 40, y: 15)
                )
                path.addLine(to: CGPoint(x: 65, y: 45))
                path.addQuadCurve(
                    to: CGPoint(x: 15, y: 45),
                    control: CGPoint(x: 40, y: 50)
                )
                path.closeSubpath()
            }
            .fill(Color.purple)
            
            // Helmet vents
            Path { path in
                // Front vent
                path.move(to: CGPoint(x: 30, y: 25))
                path.addLine(to: CGPoint(x: 50, y: 25))
                path.addLine(to: CGPoint(x: 45, y: 35))
                path.addLine(to: CGPoint(x: 35, y: 35))
                path.closeSubpath()
                
                // Side vents
                path.move(to: CGPoint(x: 25, y: 30))
                path.addLine(to: CGPoint(x: 28, y: 40))
                path.move(to: CGPoint(x: 55, y: 30))
                path.addLine(to: CGPoint(x: 52, y: 40))
            }
            .stroke(Color.purple.opacity(0.7), lineWidth: 2)
            
            // Wonkiness indicator
            Path { path in
                path.move(to: CGPoint(x: 35, y: 15))
                path.addLine(to: CGPoint(x: 45, y: 15))
                path.addCurve(
                    to: CGPoint(x: 55, y: 20),
                    control1: CGPoint(x: 48, y: 15),
                    control2: CGPoint(x: 52, y: 17)
                )
            }
            .stroke(Color.orange, style: StrokeStyle(
                lineWidth: 2,
                dash: [4, 2]
            ))
        }
        .frame(width: 80, height: 60)
        .rotationEffect(.degrees(tilt))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            HStack(spacing: 0) {
                if isLandscape {
                    // Weather section
                    weatherSection
                        .frame(width: geometry.size.width * 0.5)
                    
                    // Predictions section
                    predictionsSection
                        .frame(width: geometry.size.width * 0.5)
                } else {
                    // Portrait layout
                    VStack(spacing: 24) {
                        weatherSection
                        predictionsSection
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: backgroundColors(),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .preferredColorScheme(isDaytime ? .light : .dark)
        }
        .task {
            loadForecast()
        }
    }
    
    private var weatherSection: some View {
        VStack(spacing: 24) {
            // Weather icon
            Image(systemName: weatherIcon())
                .imageScale(.large)
                .font(.system(size: 80))
                .foregroundStyle(weatherColor())
                .frame(width: 100, height: 100)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .gray.opacity(0.3), radius: 8)
                )
                .padding(.top, 20)
            
            // Location and time info
            VStack(spacing: 8) {
                Text("Macclesfield")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Thursday at 19:45")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "sunset.fill")
                        .foregroundStyle(.orange)
                    Text(sunsetStatus)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            if let willRain = willRain, let probability = probability {
                Text(willRain ? "Yes, it will rain" : "No, it won't rain")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(willRain ? .blue : .green)
                    .multilineTextAlignment(.center)
                
                Text("\(probability)% chance of rain")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var predictionsSection: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .padding(44)
            } else if let error = error {
                errorView(error)
            } else {
                VStack(spacing: 24) {
                    // Hanno's prediction
                    VStack(spacing: 8) {
                        Text("Hanno will be")
                            .font(.title3)
                        Text("\(hannoDelay) minutes late")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                    
                    // Compass's helmet
                    VStack(spacing: 8) {
                        Text("Compass's Helmet Wonkiness")
                            .font(.title3)
                        HStack(spacing: 12) {
                            helmetIcon(tilt: Double(helmetTilt))
                            VStack(alignment: .leading) {
                                Text("\(helmetTilt)° off-center")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundStyle(.purple)
                                Text(helmetTilt > 30 ? "Very wonky!" : (helmetTilt > 15 ? "Quite wonky" : "Slightly wonky"))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                }
                
                Spacer(minLength: 0)
                
                // Refresh button
                Button(action: loadForecast) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                }
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
                .padding(.vertical)
            }
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(.red)
            
            Text("Error: \(error.localizedDescription)")
                .font(.body)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
    
    private func loadForecast() {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        willRain = nil
        probability = nil
        
        // Generate random predictions
        hannoDelay = Int.random(in: 1...15)
        helmetTilt = Int.random(in: 1...45)
        
        Task {
            do {
                let forecast = try await weatherService.getThursdayForecast()
                
                if Task.isCancelled {
                    print("Task was cancelled")
                    return
                }
                
                await MainActor.run {
                    willRain = forecast.willRain
                    probability = forecast.probability
                    isDaytime = forecast.isDaytime
                    sunsetTime = forecast.sunsetTime
                    sunsetStatus = isDaytime ? 
                        "Sunset at \(forecast.sunsetTime)" : 
                        "After sunset (\(forecast.sunsetTime))"
                    isLoading = false
                }
            } catch {
                print("Error in loadForecast: \(error.localizedDescription)")
                if !Task.isCancelled {
                    await MainActor.run {
                        self.error = error
                        isLoading = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
