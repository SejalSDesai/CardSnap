// CardRowView.swift
// CardSnap — Individual card row in the list

import SwiftUI
import SwiftData

struct CardRowView: View {
    let card: BusinessCard
    var onTap: () -> Void

    @Environment(\.modelContext) private var context
    @State private var offset: CGFloat = 0
    @State private var showDeleteConfirm = false
    @State private var appeared = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.md) {
                // Avatar
                AvatarView(card: card, size: 50)

                // Info
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(card.displayName)
                            .font(.headline)
                            .foregroundStyle(.textPrimary)

                        if card.isFavorite {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(card.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .lineLimit(1)

                    if let email = card.email {
                        Text(email)
                            .font(.caption)
                            .foregroundStyle(Color.primaryStart.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Chevron + date
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.textSecondary)

                    Text(card.scannedAt.formatted(.relative(presentation: .named)))
                        .font(.caption2)
                        .foregroundStyle(.textSecondary)
                }
            }
            .padding(Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .fill(Color.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        card.accentColor.opacity(0.35),
                                        card.accentColor.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .pressable()
        .offset(x: offset)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            // Delete
            Button(role: .destructive) {
                HapticFeedback.heavy()
                withAnimation(.spring()) {
                    context.delete(card)
                }
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }

            // Favorite toggle
            Button {
                HapticFeedback.light()
                withAnimation(.spring()) {
                    card.isFavorite.toggle()
                }
            } label: {
                Label(
                    card.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: card.isFavorite ? "star.slash.fill" : "star.fill"
                )
            }
            .tint(.yellow)
        }
    }

    func appear(delay: Double = 0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                appeared = true
            }
        }
    }
}

#Preview {
    List {
        ForEach(BusinessCard.sampleCards, id: \.id) { card in
            CardRowView(card: card, onTap: {})
                .listRowBackground(Color.clear)
                .listRowInsets(.init(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
    }
    .listStyle(.plain)
    .background(Color.appBackground)
}
