// CardSnapApp.swift
// CardSnap — App Entry Point

import SwiftUI
import SwiftData

@main
struct CardSnapApp: App {
    init() {
        // Force dark appearance at UIKit level as well
        UINavigationBar.appearance().barStyle = .black
        UITabBar.appearance().barStyle = .black
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .tint(Color(hex: "#667EEA"))
        }
        .modelContainer(for: BusinessCard.self)
    }
}
