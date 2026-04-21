// AnimatedGradientBackground.swift
// CardSnap — Animated Mesh/Orb Background

import SwiftUI

struct AnimatedGradientBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            // Orb 1 — primary purple
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.primaryStart.opacity(0.5), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 500, height: 500)
                .offset(
                    x: animate ? -80 : -120,
                    y: animate ? -200 : -160
                )
                .blur(radius: 60)

            // Orb 2 — secondary pink
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.secondaryStart.opacity(0.35), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(
                    x: animate ? 160 : 100,
                    y: animate ? 200 : 260
                )
                .blur(radius: 70)

            // Orb 3 — deep indigo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "#6366F1").opacity(0.3), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(
                    x: animate ? 40 : -20,
                    y: animate ? 80 : 40
                )
                .blur(radius: 50)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animate = true
            }
        }
    }
}

// MARK: - Static Background (for performance when not needed animated)
struct StaticGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.appBackground, Color(hex: "#1A1A2E")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    AnimatedGradientBackground()
}
