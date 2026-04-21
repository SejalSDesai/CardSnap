// CardDetailView.swift
// CardSnap — Full card detail sheet

import SwiftUI
import SwiftData
import Contacts
import ContactsUI

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Bindable var card: BusinessCard

    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var showShareSheet = false
    @State private var showExportedContact = false
    @State private var appear = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedGradientBackground()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        heroSection
                        ContactActionsRow(card: card).glassCard()
                        contactInfoSection
                        if card.imageData != nil { cardImageSection }
                        if !card.rawText.isEmpty { rawTextSection }
                        notesSection
                        metadataSection
                        Spacer().frame(height: 40)
                    }
                    .padding(.top, Spacing.md)
                    .padding(.horizontal, Spacing.md) // single padding layer
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showEditSheet) {
                EditCardView(card: card)
            }
            .confirmationDialog(
                "Delete \"\(card.displayName)\"?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    HapticFeedback.heavy()
                    context.delete(card)
                    dismiss()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1)) {
                appear = true
            }
        }
    }

    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            LargeAvatarView(card: card)

            // Name
            Text(card.displayName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)

            // Job & company
            if card.jobTitle != nil || card.company != nil {
                Text(card.subtitle)
                    .font(.headline)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            // Tags row
            HStack(spacing: Spacing.sm) {
                if card.isFavorite {
                    Label("Favorite", systemImage: "star.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.yellow.opacity(0.15), in: Capsule())
                }

                Text(card.scannedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.cardBackground, in: Capsule())
            }
        }
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
    }

    // MARK: - Contact Info Section
    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Contact Info")

            VStack(spacing: 0) {
                if let email = card.email {
                    infoRow(icon: "envelope.fill", label: "Email", value: email, color: .secondaryStart) {
                        UIApplication.shared.open(URL(string: "mailto:\(email)")!)
                    }
                    Divider().padding(.leading, 52).opacity(0.15)
                }

                if let phone = card.formattedPhone ?? card.phone {
                    infoRow(icon: "phone.fill", label: "Phone", value: phone, color: .success) {
                        let digits = (card.phone ?? "").filter(\.isNumber)
                        UIApplication.shared.open(URL(string: "tel:\(digits)")!)
                    }
                    Divider().padding(.leading, 52).opacity(0.15)
                }

                if let website = card.website {
                    infoRow(icon: "safari.fill", label: "Website", value: website, color: .warning) {
                        if let url = URL(string: website) { UIApplication.shared.open(url) }
                    }
                    Divider().padding(.leading, 52).opacity(0.15)
                }

                if let address = card.address {
                    infoRow(icon: "map.fill", label: "Address", value: address, color: .primaryStart) {
                        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        UIApplication.shared.open(URL(string: "maps://?q=\(encoded)")!)
                    }
                }
            }
            .glassCard(padding: 0)
        }
    }

    // MARK: - Card Image
    private var cardImageSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            sectionLabel("Scanned Card")
            if let data = card.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: Radius.xl, style: .continuous))
                    .cardShadow()
            }
        }
    }

    // MARK: - Raw OCR Text
    private var rawTextSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            sectionLabel("OCR Raw Text")
            ScrollView(.horizontal, showsIndicators: false) {
                Text(card.rawText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.textSecondary)
                    .padding(Spacing.md)
            }
            .glassCard(padding: 0)
        }
    }

    // MARK: - Notes
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            sectionLabel("Notes")
            Text(card.notes?.isEmpty == false ? card.notes! : "No notes yet. Edit to add notes.")
                .font(.subheadline)
                .foregroundStyle(card.notes?.isEmpty == false ? .textPrimary : .textSecondary)
                .glassCard()
        }
    }

    // MARK: - Metadata
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            sectionLabel("Details")
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Scanned")
                    Spacer()
                    Text(card.scannedAt.formatted(.dateTime.month().day().year().hour().minute()))
                        .foregroundStyle(.textSecondary)
                }
                HStack {
                    Text("Card ID")
                    Spacer()
                    Text(card.id.uuidString.prefix(8).lowercased())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.textSecondary)
                }
            }
            .font(.subheadline)
            .foregroundStyle(.textPrimary)
            .glassCard()
        }
    }

    // MARK: - Helpers
    private func sectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.textSecondary)
            .textCase(.uppercase)
            .tracking(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func infoRow(icon: String, label: String, value: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticFeedback.light()
            action()
        }) {
            HStack(spacing: Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 20)
                    .padding(.leading, Spacing.md)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(.textSecondary)
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(.textPrimary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.textSecondary)
                    .padding(.trailing, Spacing.md)
            }
            .padding(.vertical, Spacing.md)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            HStack(spacing: 4) {
                // Favorite toggle
                Button {
                    HapticFeedback.light()
                    withAnimation(.spring()) { card.isFavorite.toggle() }
                } label: {
                    Image(systemName: card.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(card.isFavorite ? .yellow : .textSecondary)
                        .symbolEffect(.bounce, value: card.isFavorite)
                }
                .frame(width: 36, height: 36)
                .background(Color.cardBackground, in: Circle())

                // Share
                Button {
                    HapticFeedback.light()
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.textSecondary)
                }
                .frame(width: 36, height: 36)
                .background(Color.cardBackground, in: Circle())
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(items: [shareText])
                }

                // More menu
                Menu {
                    Button {
                        HapticFeedback.light()
                        showEditSheet = true
                    } label: {
                        Label("Edit Card", systemImage: "pencil")
                    }

                    Button {
                        HapticFeedback.light()
                        exportToContacts()
                    } label: {
                        Label("Export to Contacts", systemImage: "person.crop.circle.badge.plus")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Card", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.textSecondary)
                        .frame(width: 36, height: 36)
                        .background(Color.cardBackground, in: Circle())
                }
            }
        }
    }

    private var shareText: String {
        var parts = [card.displayName]
        if let j = card.jobTitle { parts.append(j) }
        if let c = card.company  { parts.append(c) }
        if let e = card.email    { parts.append(e) }
        if let p = card.phone    { parts.append(p) }
        if let w = card.website  { parts.append(w) }
        return parts.joined(separator: "\n")
    }

    private func exportToContacts() {
        let contact = CNMutableContact()
        let nameParts = card.fullName.components(separatedBy: .whitespaces)
        contact.givenName  = nameParts.first ?? card.fullName
        contact.familyName = nameParts.count > 1 ? nameParts.dropFirst().joined(separator: " ") : ""
        if let c = card.company  { contact.organizationName = c }
        if let t = card.jobTitle { contact.jobTitle = t }
        if let e = card.email {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: e as NSString)]
        }
        if let p = card.phone {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: p))]
        }
        if let w = card.website, let url = URL(string: w) {
            contact.urlAddresses = [CNLabeledValue(label: CNLabelWork, value: url.absoluteString as NSString)]
        }

        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, _ in
            guard granted else { return }
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)
            try? store.execute(saveRequest)
            DispatchQueue.main.async {
                HapticFeedback.success()
            }
        }
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CardDetailView(card: BusinessCard.sampleCards[0])
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
