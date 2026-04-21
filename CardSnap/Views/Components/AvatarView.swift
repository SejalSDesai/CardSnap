// AvatarView.swift
// CardSnap — Reusable Avatar / Initials Component

import SwiftUI

struct AvatarView: View {
    let card: BusinessCard
    var size: CGFloat = 52

    @State private var appear = false

    var body: some View {
        ZStack {
            if let data = card.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .scaleEffect(appear ? 1 : 0.5)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.65).delay(0.05)) {
                appear = true
            }
        }
    }

    private var initialsView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [card.accentColor, card.accentColor.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1.5)
                }

            Text(card.initials)
                .font(.system(size: size * 0.36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Large Avatar (for detail view)
struct LargeAvatarView: View {
    let card: BusinessCard
    var size: CGFloat = 88

    var body: some View {
        AvatarView(card: card, size: size)
            .shadow(color: card.accentColor.opacity(0.5), radius: 20, x: 0, y: 8)
    }
}

#Preview {
    HStack(spacing: 16) {
        ForEach(BusinessCard.sampleCards, id: \.id) { card in
            AvatarView(card: card)
        }
    }
    .padding()
    .background(Color.appBackground)
}
