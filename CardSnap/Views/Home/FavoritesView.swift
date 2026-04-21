// FavoritesView.swift
// CardSnap — Favorites tab

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(
        filter: #Predicate<BusinessCard> { $0.isFavorite == true },
        sort: \BusinessCard.fullName
    ) private var favorites: [BusinessCard]

    @State private var selectedCard: BusinessCard?

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()

                if favorites.isEmpty {
                    EmptyStateView(
                        title: "No Favorites",
                        subtitle: "Swipe left on a card and tap ⭐️\nto add it to your favorites.",
                        systemImage: "star.slash.fill"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.sm) {
                            ForEach(favorites, id: \.id) { card in
                                CardRowView(card: card) {
                                    HapticFeedback.selection()
                                    selectedCard = card
                                }
                                .padding(.horizontal, Spacing.md)
                            }
                        }
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
