// Color+Extensions.swift
// CardSnap — Design System: Colors & Gradients

import SwiftUI

extension Color {
    // MARK: - Brand Gradients (as static colors for gradient stops)
    static let primaryStart   = Color(hex: "#667EEA") // purple-blue
    static let primaryEnd     = Color(hex: "#764BA2") // deep purple
    static let secondaryStart = Color(hex: "#F093FB") // pink
    static let secondaryEnd   = Color(hex: "#F5576C") // coral-red

    // MARK: - Backgrounds
    static let appBackground      = Color(hex: "#0F0F23") // dark navy
    static let appBackgroundLight = Color(hex: "#F8FAFC")
    static let cardBackground     = Color(hex: "#1A1A2E")
    static let cardBackgroundAlt  = Color(hex: "#16213E")

    // MARK: - Accent
    static let success = Color(hex: "#10B981")
    static let warning = Color(hex: "#F59E0B")
    static let error   = Color(hex: "#EF4444")

    // MARK: - Text
    static let textPrimary   = Color(hex: "#FFFFFF")
    static let textSecondary = Color(hex: "#94A3B8")
    static let textDark      = Color(hex: "#1E293B")

    // MARK: - Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - ShapeStyle extensions (enables dot-syntax in .foregroundStyle())
// e.g. .foregroundStyle(.textPrimary) instead of .foregroundStyle(Color.textPrimary)
extension ShapeStyle where Self == Color {
    static var primaryStart:   Color { Color(hex: "#667EEA") }
    static var primaryEnd:     Color { Color(hex: "#764BA2") }
    static var secondaryStart: Color { Color(hex: "#F093FB") }
    static var secondaryEnd:   Color { Color(hex: "#F5576C") }
    static var appBackground:  Color { Color(hex: "#0F0F23") }
    static var cardBackground: Color { Color(hex: "#1A1A2E") }
    static var success:        Color { Color(hex: "#10B981") }
    static var warning:        Color { Color(hex: "#F59E0B") }
    static var error:          Color { Color(hex: "#EF4444") }
    static var textPrimary:    Color { Color(hex: "#FFFFFF") }
    static var textSecondary:  Color { Color(hex: "#94A3B8") }
    static var textDark:       Color { Color(hex: "#1E293B") }
}

// MARK: - Gradient Presets
extension LinearGradient {
    static let primary = LinearGradient(
        colors: [.primaryStart, .primaryEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let secondary = LinearGradient(
        colors: [.secondaryStart, .secondaryEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardGlow = LinearGradient(
        colors: [Color.primaryStart.opacity(0.4), Color.primaryEnd.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let darkCard = LinearGradient(
        colors: [Color(hex: "#1A1A2E"), Color(hex: "#16213E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

