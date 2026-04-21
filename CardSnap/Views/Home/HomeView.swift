// HomeView.swift
// CardSnap — Main cards list screen

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \BusinessCard.scannedAt, order: .reverse) private var cards: [BusinessCard]

    @State private var searchText = ""
    @State private var showScanSheet = false
    @State private var selectedCard: BusinessCard?
    @State private var viewMode: ViewMode = .list
    @State private var headerAppeared = false

    enum ViewMode: String, CaseIterable {
        case list = "list.bullet"
        case grid = "square.grid.2x2.fill"
    }

    var filteredCards: [BusinessCard] {
        guard !searchText.isEmpty else { return cards }
        return cards.filter { $0.searchableText.contains(searchText.lowercased()) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AnimatedGradientBackground()

                if cards.isEmpty {
                    EmptyStateView(
                        title: "No Cards Yet",
                        subtitle: "Tap the button below to scan\nyour first business card.",
                        systemImage: "rectangle.stack.badge.plus"
                    ) {
                        showScanSheet = true
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: Spacing.sm, pinnedViews: []) {
                            // Stats header
                            statsHeader
                                .padding(.horizontal, Spacing.md)
                                .padding(.top, Spacing.sm)

                            // Recent header
                            if !filteredCards.isEmpty {
                                sectionHeader("All Cards (\(filteredCards.count))")
                                    .padding(.horizontal, Spacing.md)
                            }

                            // Cards
                            if viewMode == .list {
                                listContent
                            } else {
                                gridContent
                            }
                        }
                        .padding(.bottom, 120) // clear the tab bar
                    }
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar { toolbarContent }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search cards…")
            .sheet(isPresented: $showScanSheet) {
                ScanView()
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: Spacing.md) {
            StatPill(
                value: "\(cards.count)",
                label: "Total",
                icon: "rectangle.stack.fill",
                color: .primaryStart
            )
            StatPill(
                value: "\(cards.filter(\.isFavorite).count)",
                label: "Starred",
                icon: "star.fill",
                color: .yellow
            )
            StatPill(
                value: recentCount,
                label: "This week",
                icon: "clock.fill",
                color: .success
            )
        }
    }

    private var recentCount: String {
        let weekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: .now) ?? .now
        return "\(cards.filter { $0.scannedAt > weekAgo }.count)"
    }

    // MARK: - List content
    @ViewBuilder
    private var listContent: some View {
        if filteredCards.isEmpty && !searchText.isEmpty {
            SearchEmptyStateView(query: searchText)
                .padding(.top, Spacing.xxxl)
        } else {
            ForEach(Array(filteredCards.enumerated()), id: \.element.id) { index, card in
                CardRowView(card: card) {
                    HapticFeedback.selection()
                    selectedCard = card
                }
                .padding(.horizontal, Spacing.md)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal:   .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    // MARK: - Grid content
    @ViewBuilder
    private var gridContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
            ForEach(filteredCards, id: \.id) { card in
                GradientCardView(card: card)
                    .onTapGesture {
                        HapticFeedback.selection()
                        selectedCard = card
                    }
            }
        }
        .padding(.horizontal, Spacing.md)
    }

    // MARK: - Section header
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            Spacer()
        }
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            VStack(alignment: .leading, spacing: 1) {
                Text("CardSnap")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(LinearGradient.primary)
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 8) {
                // View mode toggle
                Button {
                    HapticFeedback.selection()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewMode = viewMode == .list ? .grid : .list
                    }
                } label: {
                    Image(systemName: viewMode.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Color.cardBackground, in: Circle())
                }
                .buttonStyle(.plain)

                // Scan button
                Button {
                    HapticFeedback.medium()
                    showScanSheet = true
                } label: {
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(LinearGradient.primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Stat Pill
struct StatPill: View {
    let value: String
    let label: String
    let icon: String
    var color: Color = .primaryStart

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.textPrimary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.textSecondary)
            }
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xs)
        .background(Color.cardBackground, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
