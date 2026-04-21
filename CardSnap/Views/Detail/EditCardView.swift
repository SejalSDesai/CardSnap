// EditCardView.swift
// CardSnap — Edit/correct a scanned business card

import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var card: BusinessCard

    @State private var showColorPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Live card preview
                        GradientCardView(card: card)
                            .padding(.horizontal, Spacing.md)
                            .padding(.top, Spacing.md)

                        // Color picker for card accent
                        colorPickerSection

                        // Fields
                        formSection("Identity") {
                            EditField("Full Name",  icon: "person.fill",       text: $card.fullName)
                            EditField("Company",    icon: "building.2.fill",   text: nilBind($card.company))
                            EditField("Job Title",  icon: "briefcase.fill",    text: nilBind($card.jobTitle))
                        }

                        formSection("Contact") {
                            EditField("Email",    icon: "envelope.fill",  text: nilBind($card.email),   keyboard: .emailAddress)
                            EditField("Phone",    icon: "phone.fill",     text: nilBind($card.phone),   keyboard: .phonePad)
                            EditField("Website",  icon: "safari.fill",    text: nilBind($card.website), keyboard: .URL)
                        }

                        formSection("Social") {
                            EditField("LinkedIn", icon: "link.circle.fill", text: nilBind($card.linkedIn), keyboard: .URL)
                            EditField("Twitter",  icon: "at.circle.fill",   text: nilBind($card.twitter))
                        }

                        formSection("Location & Notes") {
                            EditField("Address", icon: "map.fill", text: nilBind($card.address))
                            EditTextArea("Notes", icon: "note.text", text: nilBind($card.notes))
                        }

                        Spacer().frame(height: 60)
                    }
                }
            }
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.light()
                        dismiss()
                    }
                    .foregroundStyle(.textSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        HapticFeedback.success()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.primaryStart)
                }
            }
        }
    }

    // MARK: - Color Picker
    private var colorPickerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Card Color")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.leading, Spacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(BusinessCard.availableTagColors, id: \.hex) { item in
                        Button {
                            HapticFeedback.selection()
                            withAnimation(.spring()) { card.tagColor = item.hex }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: item.hex))
                                    .frame(width: 36, height: 36)

                                if card.tagColor == item.hex {
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 3)
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .pressable()
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    // MARK: - Section builder
    private func formSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.leading, Spacing.xs)
                .padding(.bottom, Spacing.sm)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: 0) {
                content()
            }
            .glassCard(padding: 0)
            .padding(.horizontal, Spacing.md)
        }
    }

    // Nil string binding helper
    private func nilBind(_ binding: Binding<String?>) -> Binding<String> {
        Binding(
            get: { binding.wrappedValue ?? "" },
            set: { binding.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}

// MARK: - Edit Field
struct EditField: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    init(_ label: String, icon: String, text: Binding<String>, keyboard: UIKeyboardType = .default) {
        self.label = label
        self.icon = icon
        self._text = text
        self.keyboard = keyboard
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primaryStart)
                .frame(width: 20)
                .padding(.leading, Spacing.md)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)

                TextField(label, text: $text)
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled(keyboard != .default)
                    .textInputAutocapitalization(keyboard == .emailAddress || keyboard == .URL ? .never : .words)
            }
            .padding(.vertical, Spacing.md)

            Spacer()
        }
    }
}

// MARK: - Edit Text Area
struct EditTextArea: View {
    let label: String
    let icon: String
    @Binding var text: String

    init(_ label: String, icon: String, text: Binding<String>) {
        self.label = label
        self.icon = icon
        self._text = text
    }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primaryStart)
                .frame(width: 20)
                .padding(.leading, Spacing.md)
                .padding(.top, Spacing.md)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .padding(.top, Spacing.md)

                TextField(label, text: $text, axis: .vertical)
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .lineLimit(3...6)
                    .padding(.bottom, Spacing.md)
            }

            Spacer()
        }
    }
}

#Preview {
    EditCardView(card: BusinessCard.sampleCards[0])
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
