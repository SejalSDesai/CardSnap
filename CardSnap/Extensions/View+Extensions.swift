// View+Extensions.swift
// CardSnap — Design System: View Modifiers & Helpers

import SwiftUI

// MARK: - Spacing Constants
enum Spacing {
    static let xs: CGFloat     = 4
    static let sm: CGFloat     = 8
    static let md: CGFloat     = 16
    static let lg: CGFloat     = 20
    static let xl: CGFloat     = 24
    static let xxl: CGFloat    = 32
    static let xxxl: CGFloat   = 48
}

// MARK: - Corner Radius Constants
enum Radius {
    static let sm: CGFloat  = 8
    static let md: CGFloat  = 12
    static let lg: CGFloat  = 16
    static let xl: CGFloat  = 20
    static let xxl: CGFloat = 28
    static let pill: CGFloat = 999
}

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = Spacing.lg
    var cornerRadius: CGFloat = Radius.xl

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.cardBackground.opacity(0.85))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.03)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
    }
}

// MARK: - Gradient Button Modifier
struct GradientButtonModifier: ViewModifier {
    var gradient: LinearGradient = .primary
    var height: CGFloat = 54

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
            .shadow(color: Color.primaryEnd.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Press Scale Effect
struct PressableModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Shimmer Loading Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geo in
                    let width = geo.size.width
                    LinearGradient(
                        stops: [
                            .init(color: .clear,                       location: phase - 0.3),
                            .init(color: .white.opacity(0.4),          location: phase),
                            .init(color: .clear,                       location: phase + 0.3)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: -width + phase * width * 2)
                }
            }
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

// MARK: - View Extension Helpers
extension View {
    func glassCard(padding: CGFloat = Spacing.lg, cornerRadius: CGFloat = Radius.xl) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }

    func gradientButton(gradient: LinearGradient = .primary, height: CGFloat = 54) -> some View {
        modifier(GradientButtonModifier(gradient: gradient, height: height))
    }

    func pressable() -> some View {
        modifier(PressableModifier())
    }

    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }

    func cardShadow(color: Color = .primaryEnd, opacity: Double = 0.2) -> some View {
        self.shadow(color: color.opacity(opacity), radius: 16, x: 0, y: 8)
    }

    /// Hide view conditionally without removing from layout
    @ViewBuilder
    func visible(_ isVisible: Bool) -> some View {
        if isVisible { self } else { self.hidden() }
    }
}

// MARK: - Haptic Feedback
enum HapticFeedback {
    static func light()     { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func medium()    { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    static func heavy()     { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
    static func success()   { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    static func error()     { UINotificationFeedbackGenerator().notificationOccurred(.error) }
    static func selection() { UISelectionFeedbackGenerator().selectionChanged() }
}
