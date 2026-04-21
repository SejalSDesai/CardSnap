// ScanView.swift
// CardSnap — Camera + OCR scan flow

import SwiftUI
import SwiftData
import PhotosUI
import VisionKit

struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var ocr = OCRProcessor()
    @State private var scanStep: ScanStep = .camera
    @State private var capturedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var editedCard: BusinessCard?
    @State private var showSaveSuccess = false
    @State private var cameraError: String?

    enum ScanStep {
        case camera, processing, review, success
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                switch scanStep {
                case .camera:   cameraStep
                case .processing: processingStep
                case .review:   if let card = editedCard { reviewStep(card: card) }
                case .success:  successStep
                }
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        HapticFeedback.light()
                        dismiss()
                    }
                    .foregroundStyle(.textSecondary)
                }
            }
            .onChange(of: photoItem) { _, item in
                Task {
                    guard let item,
                          let data = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    await processImage(image)
                }
            }
        }
    }

    // MARK: - Step Titles
    private var stepTitle: String {
        switch scanStep {
        case .camera:     return "Scan Card"
        case .processing: return "Reading Card…"
        case .review:     return "Review & Save"
        case .success:    return "Saved!"
        }
    }

    // MARK: - Camera Step
    private var cameraStep: some View {
        VStack(spacing: Spacing.xl) {
            // Preview placeholder / instructions
            ZStack {
                RoundedRectangle(cornerRadius: Radius.xxl, style: .continuous)
                    .fill(Color.cardBackground)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1.586, contentMode: .fit)
                    .overlay {
                        RoundedRectangle(cornerRadius: Radius.xxl, style: .continuous)
                            .strokeBorder(
                                LinearGradient.primary,
                                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                            )
                    }
                    .padding(.horizontal, Spacing.xl)

                VStack(spacing: Spacing.md) {
                    Image(systemName: "rectangle.dashed.badge.plus")
                        .font(.system(size: 44))
                        .foregroundStyle(LinearGradient.primary)

                    Text("Position the business card\nwithin the frame")
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            // Action buttons
            VStack(spacing: Spacing.md) {
                // Scan with camera
                if DataScannerViewController.isSupported {
                    DocumentScannerButton { image in
                        Task { await processImage(image) }
                    }
                    .gradientButton()
                    .padding(.horizontal, Spacing.xl)
                }

                // Pick from photos
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Choose from Photos", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.cardBackground)
                        .foregroundStyle(.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        }
                }
                .padding(.horizontal, Spacing.xl)
                .pressable()
            }
            .padding(.top, Spacing.md)

            Spacer()
        }
        .padding(.top, Spacing.xl)
    }

    // MARK: - Processing Step
    private var processingStep: some View {
        VStack(spacing: Spacing.xxl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient.cardGlow)
                    .frame(width: 140, height: 140)

                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay {
                            Circle().strokeBorder(LinearGradient.primary, lineWidth: 3)
                        }
                        .overlay {
                            // Spinning overlay
                            Circle()
                                .trim(from: 0, to: 0.25)
                                .stroke(Color.primaryStart, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                .rotationEffect(.degrees(ocr.isProcessing ? 360 : 0))
                                .animation(
                                    .linear(duration: 1).repeatForever(autoreverses: false),
                                    value: ocr.isProcessing
                                )
                        }
                }
            }

            VStack(spacing: Spacing.sm) {
                Text("Analysing Card…")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.textPrimary)

                Text("Extracting contact information\nusing Vision OCR")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }

    // MARK: - Review Step
    @ViewBuilder
    private func reviewStep(card: BusinessCard) -> some View {
        ScrollView {
            VStack(spacing: Spacing.xl) {
                // Card preview
                GradientCardView(card: card)
                    .padding(.horizontal, Spacing.md)

                // Edit fields
                VStack(spacing: Spacing.md) {
                    FieldEditor(label: "Full Name",   icon: "person.fill",        text: Binding(get: { card.fullName },  set: { card.fullName = $0 }))
                    FieldEditor(label: "Company",     icon: "building.2.fill",    text: nilBinding(card.company)  { card.company = $0 })
                    FieldEditor(label: "Job Title",   icon: "briefcase.fill",     text: nilBinding(card.jobTitle) { card.jobTitle = $0 })
                    FieldEditor(label: "Email",       icon: "envelope.fill",      text: nilBinding(card.email)    { card.email = $0 }, keyboard: .emailAddress)
                    FieldEditor(label: "Phone",       icon: "phone.fill",         text: nilBinding(card.phone)    { card.phone = $0 }, keyboard: .phonePad)
                    FieldEditor(label: "Website",     icon: "safari.fill",        text: nilBinding(card.website)  { card.website = $0 }, keyboard: .URL)
                }
                .glassCard()
                .padding(.horizontal, Spacing.md)

                // Save button
                Button {
                    HapticFeedback.success()
                    saveCard(card)
                } label: {
                    Label("Save to CardSnap", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .gradientButton()
                }
                .padding(.horizontal, Spacing.xl)
                .pressable()

                Spacer().frame(height: 40)
            }
            .padding(.top, Spacing.md)
        }
    }

    // MARK: - Success Step
    private var successStep: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.success.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.success)
                    .symbolEffect(.bounce)
            }

            VStack(spacing: Spacing.sm) {
                Text("Card Saved!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.textPrimary)

                Text("The contact has been added\nto your CardSnap library.")
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button("Done") {
                HapticFeedback.light()
                dismiss()
            }
            .gradientButton()
            .padding(.horizontal, Spacing.xl)
            .pressable()

            Button("Scan Another") {
                HapticFeedback.light()
                withAnimation(.spring()) {
                    scanStep = .camera
                    capturedImage = nil
                    editedCard = nil
                }
            }
            .font(.subheadline)
            .foregroundStyle(.textSecondary)

            Spacer()
        }
    }

    // MARK: - Actions
    private func processImage(_ image: UIImage) async {
        capturedImage = image
        withAnimation(.spring()) { scanStep = .processing }

        await ocr.processImage(image)

        if let card = ocr.extractedCard {
            editedCard = card
            withAnimation(.spring()) { scanStep = .review }
        } else {
            // Fallback: create empty card
            editedCard = BusinessCard(fullName: "", imageData: image.jpegData(compressionQuality: 0.8))
            withAnimation(.spring()) { scanStep = .review }
        }
    }

    private func saveCard(_ card: BusinessCard) {
        context.insert(card)
        withAnimation(.spring()) { scanStep = .success }
    }

    // Helper: binding for optional strings
    private func nilBinding(_ value: String?, setter: @escaping (String?) -> Void) -> Binding<String> {
        Binding(
            get: { value ?? "" },
            set: { setter($0.isEmpty ? nil : $0) }
        )
    }
}

// MARK: - Document Scanner Button (wraps VisionKit DataScannerVC)
struct DocumentScannerButton: View {
    var onCapture: (UIImage) -> Void
    @State private var showScanner = false

    var body: some View {
        Button {
            showScanner = true
        } label: {
            Label("Scan with Camera", systemImage: "camera.fill")
                .font(.headline)
        }
        .sheet(isPresented: $showScanner) {
            DocumentScannerRepresentable(onCapture: onCapture)
                .ignoresSafeArea()
        }
    }
}

// MARK: - UIDocumentCameraViewController wrapper
import VisionKit

struct DocumentScannerRepresentable: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onCapture: onCapture) }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let vc = VNDocumentCameraViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onCapture: (UIImage) -> Void
        init(onCapture: @escaping (UIImage) -> Void) { self.onCapture = onCapture }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            guard scan.pageCount > 0 else { controller.dismiss(animated: true); return }
            let image = scan.imageOfPage(at: 0)
            controller.dismiss(animated: true) { self.onCapture(image) }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
        }
    }
}

// MARK: - Field Editor
struct FieldEditor: View {
    let label: String
    let icon: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primaryStart)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.textSecondary)

                TextField(label, text: $text)
                    .font(.subheadline)
                    .foregroundStyle(.textPrimary)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(keyboard == .emailAddress || keyboard == .URL ? .never : .words)
            }
        }
    }
}

#Preview {
    ScanView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
