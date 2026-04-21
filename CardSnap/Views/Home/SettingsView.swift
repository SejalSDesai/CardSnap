// SettingsView.swift
// CardSnap — App settings (alignment fixed: single padding layer at scroll level)

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var cards: [BusinessCard]

    @AppStorage("hapticEnabled")     private var hapticEnabled = true
    @AppStorage("defaultViewMode")   private var defaultGridMode = false
    @AppStorage("autoSaveContacts")  private var autoSaveContacts = false

    @State private var showDeleteAllConfirm = false
    @State private var showSampleDataAdded = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        statsBanner
                        settingsSection("Preferences") {
                            SettingsToggle(icon: "hand.tap.fill",                       label: "Haptic Feedback",       color: .primaryStart,   isOn: $hapticEnabled)
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsToggle(icon: "square.grid.2x2.fill",               label: "Default Grid View",     color: .secondaryStart, isOn: $defaultGridMode)
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsToggle(icon: "person.crop.circle.badge.checkmark", label: "Auto-Save to Contacts", color: .success,        isOn: $autoSaveContacts)
                        }

                        settingsSection("Data") {
                            SettingsRow(icon: "person.3.fill",           label: "Load Sample Cards", color: .primaryStart) { loadSampleData() }
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsRow(icon: "square.and.arrow.up.fill", label: "Export All Cards",  color: .warning)     { exportAllCards() }
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsRow(icon: "trash.fill",              label: "Delete All Cards",  color: .error)       { showDeleteAllConfirm = true }
                        }

                        settingsSection("About") {
                            SettingsInfoRow(icon: "info.circle.fill",    label: "Version",    value: "1.0.0",           color: .primaryStart)
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsInfoRow(icon: "sparkles",             label: "Built with", value: "SwiftUI + Vision", color: .secondaryStart)
                            Divider().opacity(0.15).padding(.leading, 58)
                            SettingsInfoRow(icon: "rectangle.stack.fill", label: "Cards",      value: "\(cards.count)",  color: .success)
                        }

                        Text("CardSnap © 2024\nMade with ♥ using SwiftUI & VisionKit")
                            .font(.caption)
                            .foregroundStyle(.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, Spacing.sm)

                        Spacer().frame(height: 80)
                    }
                    .padding(.top, Spacing.md)
                    .padding(.horizontal, Spacing.md) // ← single horizontal padding here
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .overlay(alignment: .top) {
                if showSampleDataAdded {
                    Label("Sample cards added!", systemImage: "checkmark.circle.fill")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(Color.success, in: Capsule())
                        .padding(.top, 100)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .confirmationDialog(
                "Delete all \(cards.count) cards?",
                isPresented: $showDeleteAllConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete All", role: .destructive) {
                    HapticFeedback.heavy()
                    cards.forEach { context.delete($0) }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    // MARK: - Stats Banner
    private var statsBanner: some View {
        HStack(spacing: 0) {
            statCell(value: "\(cards.count)",                       label: "Cards",     icon: "rectangle.stack.fill")
            Divider().frame(height: 40).opacity(0.2)
            statCell(value: "\(cards.filter(\.isFavorite).count)", label: "Favorites", icon: "star.fill")
            Divider().frame(height: 40).opacity(0.2)
            statCell(value: "\(companiesCount)",                    label: "Companies", icon: "building.2.fill")
        }
        .glassCard()
    }

    private var companiesCount: Int { Set(cards.compactMap(\.company)).count }

    private func statCell(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(LinearGradient.primary)
            Text(value).font(.title2).fontWeight(.bold).foregroundStyle(.textPrimary)
            Text(label).font(.caption2).foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Section builder (no inner horizontal padding — handled at scroll level)
    private func settingsSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                content()
            }
            .background(Color.cardBackground.opacity(0.85), in: RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: Radius.xl, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            }
        }
    }

    private func loadSampleData() {
        HapticFeedback.success()
        BusinessCard.sampleCards.forEach { context.insert($0) }
        withAnimation(.spring()) { showSampleDataAdded = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSampleDataAdded = false }
        }
    }

    private func exportAllCards() {
        let lines = cards.map { [$0.fullName, $0.company, $0.jobTitle, $0.email, $0.phone, $0.website].compactMap { $0 }.joined(separator: ",") }
        let csv = (["Name,Company,Title,Email,Phone,Website"] + lines).joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("CardSnap_Export.csv")
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?.present(av, animated: true)
    }
}

// MARK: - Settings Row Types
struct SettingsToggle: View {
    let icon: String; let label: String; var color: Color = .primaryStart; @Binding var isOn: Bool
    var body: some View {
        HStack(spacing: Spacing.md) {
            iconBox(icon, color: color)
            Text(label).font(.subheadline).foregroundStyle(.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(.primaryStart)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
    }
}

struct SettingsRow: View {
    let icon: String; let label: String; var color: Color = .primaryStart; var action: () -> Void
    var body: some View {
        Button(action: { HapticFeedback.light(); action() }) {
            HStack(spacing: Spacing.md) {
                iconBox(icon, color: color)
                Text(label).font(.subheadline).foregroundStyle(color == Color.error ? color : Color.textPrimary)
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.textSecondary)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

struct SettingsInfoRow: View {
    let icon: String; let label: String; let value: String; var color: Color = .primaryStart
    var body: some View {
        HStack(spacing: Spacing.md) {
            iconBox(icon, color: color)
            Text(label).font(.subheadline).foregroundStyle(.textPrimary)
            Spacer()
            Text(value).font(.subheadline).foregroundStyle(.textSecondary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 12)
    }
}

private func iconBox(_ name: String, color: Color) -> some View {
    Image(systemName: name)
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)
        .frame(width: 30, height: 30)
        .background(color, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
}

#Preview {
    SettingsView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
