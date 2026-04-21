// ContactActionButton.swift
// CardSnap — Quick action buttons for contact interactions

import SwiftUI

struct ContactActionButton: View {
    let icon: String
    let label: String
    var color: Color = .primaryStart
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                        .fill(color.opacity(0.18))
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(color)
                }

                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .pressable()
    }
}

// MARK: - Row of 4 action buttons
struct ContactActionsRow: View {
    let card: BusinessCard

    var body: some View {
        HStack(spacing: Spacing.lg) {
            if let phone = card.phone {
                ContactActionButton(
                    icon: "phone.fill",
                    label: "Call",
                    color: .success
                ) {
                    if let url = URL(string: "tel:\(phone.filter(\.isNumber))") {
                        UIApplication.shared.open(url)
                    }
                }

                ContactActionButton(
                    icon: "message.fill",
                    label: "Message",
                    color: .primaryStart
                ) {
                    if let url = URL(string: "sms:\(phone.filter(\.isNumber))") {
                        UIApplication.shared.open(url)
                    }
                }
            }

            if let email = card.email {
                ContactActionButton(
                    icon: "envelope.fill",
                    label: "Email",
                    color: .secondaryStart
                ) {
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }
            }

            if let website = card.website {
                ContactActionButton(
                    icon: "safari.fill",
                    label: "Website",
                    color: .warning
                ) {
                    if let url = URL(string: website) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground.ignoresSafeArea()
        ContactActionsRow(card: BusinessCard.sampleCards[0])
    }
}
