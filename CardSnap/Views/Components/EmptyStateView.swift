// EmptyStateView.swift
// CardSnap — Empty State with animation

import SwiftUI

struct EmptyStateView: View {
    var title: String = "No Cards Yet"
    var subtitle: String = "Tap the scan button below\nto capture your first business card."
    var systemImage: String = "rectangle.stack.badge.plus"
    var action: (() -> Void)? = nil
    var actionTitle: String = "Scan a Card"

    @State private var bounce = false

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(LinearGradient.cardGlow)
                    .frame(width: 100, height: 100)

                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient.primary)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
                    .offset(y: bounce ? -6 : 0)
            }
            .shadow(color: .primaryStart.opacity(0.3), radius: 20, x: 0, y: 8)

            // Text
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.textPrimary)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Optional CTA
            if let action {
                Button(action: {
                    HapticFeedback.medium()
                    action()
                }) {
                    Label(actionTitle, systemImage: "viewfinder")
                        .font(.headline)
                        .gradientButton()
                        .padding(.horizontal, Spacing.xxxl)
                }
                .pressable()
            }
        }
        .padding(Spacing.xl)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bounce = true
            }
        }
    }
}

// MARK: - Search Empty State
struct SearchEmptyStateView: View {
    var query: String

    var body: some View {
        EmptyStateView(
            title: "No Results",
            subtitle: "No cards match \"\(query)\".\nTry a different name or company.",
            systemImage: "magnifyingglass"
        )
    }
}

#Preview {
    ZStack {
        AnimatedGradientBackground()
        EmptyStateView()
    }
}
