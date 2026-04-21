// GradientCardView.swift
// CardSnap — Visual business card representation

import SwiftUI

/// A stylized preview of a scanned business card (portrait-style).
struct GradientCardView: View {
    let card: BusinessCard
    var isCompact: Bool = false

    @State private var appear = false

    private let cardRatio: CGFloat = 1.586 // standard card ratio 85.6mm × 53.98mm

    var body: some View {
        let baseHeight: CGFloat = isCompact ? 100 : 180

        ZStack {
            // Background
            RoundedRectangle(cornerRadius: isCompact ? Radius.md : Radius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            card.accentColor,
                            card.accentColor.opacity(0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    // Decorative circles
                    GeometryReader { geo in
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: geo.size.height * 1.6)
                            .offset(x: geo.size.width * 0.4, y: -geo.size.height * 0.4)

                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: geo.size.height)
                            .offset(x: -geo.size.width * 0.2, y: geo.size.height * 0.3)
                    }
                    .clipped()
                }

            // Card Content
            VStack(alignment: .leading, spacing: isCompact ? 4 : 8) {
                // Company logo / initials
                if !isCompact {
                    Text(card.initials)
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(.white.opacity(0.25))
                }

                Spacer()

                // Name & title
                VStack(alignment: .leading, spacing: isCompact ? 2 : 4) {
                    Text(card.displayName)
                        .font(isCompact ? .subheadline : .title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if let company = card.company {
                        Text(company)
                            .font(isCompact ? .caption2 : .subheadline)
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                    }

                    if let jobTitle = card.jobTitle, !isCompact {
                        Text(jobTitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }

                // Contact row
                if !isCompact {
                    HStack(spacing: Spacing.sm) {
                        if let email = card.email {
                            Label(email, systemImage: "envelope.fill")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
            }
            .padding(isCompact ? Spacing.sm : Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Favorite badge
            if card.isFavorite {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(6)
                    .background(.black.opacity(0.25), in: Circle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(isCompact ? 6 : 10)
            }
        }
        .frame(height: baseHeight)
        .clipShape(RoundedRectangle(cornerRadius: isCompact ? Radius.md : Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: isCompact ? Radius.md : Radius.xl, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        }
        .scaleEffect(appear ? 1 : 0.92)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                appear = true
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(BusinessCard.sampleCards, id: \.id) { card in
                GradientCardView(card: card)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .background(Color.appBackground)
}
