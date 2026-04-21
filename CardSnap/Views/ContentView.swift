// ContentView.swift
// CardSnap — Root Tab Navigation (fixed: manual ZStack switching, no TabView page style)

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    @State private var showScanSheet = false

    enum Tab: Int, CaseIterable {
        case home, favorites, settings

        var title: String {
            switch self {
            case .home:      return "Cards"
            case .favorites: return "Favorites"
            case .settings:  return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .home:      return "rectangle.stack.fill"
            case .favorites: return "star.fill"
            case .settings:  return "gearshape.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dark background always visible beneath everything
            Color(hex: "#0F0F23").ignoresSafeArea()

            // MARK: - Tab Content (manual switching — no TabView page style)
            Group {
                HomeView()
                    .opacity(selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(selectedTab == .home)

                FavoritesView()
                    .opacity(selectedTab == .favorites ? 1 : 0)
                    .allowsHitTesting(selectedTab == .favorites)

                SettingsView()
                    .opacity(selectedTab == .settings ? 1 : 0)
                    .allowsHitTesting(selectedTab == .settings)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - Custom Tab Bar
            CustomTabBar(
                selectedTab: $selectedTab,
                showScanSheet: $showScanSheet
            )
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showScanSheet) {
            ScanView()
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showScanSheet: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                // Insert scan button in the middle
                if tab == .favorites {
                    scanButton
                }
                tabButton(tab)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.bottom, 28)
        .padding(.top, Spacing.sm)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Divider().opacity(0.3)
                }
                .ignoresSafeArea(edges: .bottom)
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: ContentView.Tab) -> some View {
        let isSelected = selectedTab == tab
        Button {
            HapticFeedback.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                    .symbolEffect(.bounce, value: isSelected)
                Text(tab.title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundStyle(
                isSelected
                    ? AnyShapeStyle(LinearGradient.primary)
                    : AnyShapeStyle(Color.gray.opacity(0.7))
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private var scanButton: some View {
        Button {
            HapticFeedback.medium()
            showScanSheet = true
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient.primary)
                    .frame(width: 58, height: 58)
                    .shadow(color: Color(hex: "#764BA2").opacity(0.6), radius: 14, x: 0, y: 5)

                Image(systemName: "viewfinder")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            .offset(y: -18)
        }
        .buttonStyle(.plain)
        .frame(width: 80)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
