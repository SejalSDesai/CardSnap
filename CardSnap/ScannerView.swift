import SwiftUI
import VisionKit

struct CardScannerSheet: View {
    let onSave: (BusinessCard) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var currentStrings: [String] = []
    @State private var capturedCard: BusinessCard? = nil
    @State private var showEdit = false

    var body: some View {
        ZStack(alignment: .top) {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                DataScannerRepresentable { strings in currentStrings = strings }
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                Text("Camera not available.").foregroundColor(.white).padding(.top, 120)
            }
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill").font(.title2)
                        .foregroundStyle(.white, .white.opacity(0.25))
                }.padding()
                Spacer()
                Text("Point at a business card").font(.caption).foregroundColor(.white.opacity(0.85)).padding(.trailing)
            }
            .background(LinearGradient(colors:[.black.opacity(0.55),.clear],startPoint:.top,endPoint:.bottom).ignoresSafeArea())
            VStack {
                Spacer()
                VStack(spacing:10) {
                    Text(currentStrings.isEmpty ? "Scanning…" : "\(currentStrings.count) text item(s) detected")
                        .font(.caption).foregroundColor(.white.opacity(0.8))
                    Button {
                        capturedCard = CardParser.parse(currentStrings)
                        showEdit = true
                    } label: {
                        ZStack {
                            Circle().stroke(Color.white.opacity(0.4),lineWidth:3).frame(width:80,height:80)
                            Circle().fill(Color.white).frame(width:66,height:66)
                        }
                    }
                    .disabled(currentStrings.isEmpty).opacity(currentStrings.isEmpty ? 0.4 : 1)
                }
                .padding(.bottom,52).frame(maxWidth:.infinity)
                .background(LinearGradient(colors:[.clear,.black.opacity(0.65)],startPoint:.top,endPoint:.bottom))
            }
        }
        .sheet(isPresented:$showEdit) {
            if let card = capturedCard {
                CardEditView(card:card, isNew:true) { savedCard in onSave(savedCard); dismiss() }
            }
        }
    }
}

private struct DataScannerRepresentable: UIViewControllerRepresentable {
    let onUpdate: ([String]) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(onUpdate: onUpdate) }
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(recognizedDataTypes:[.text()],qualityLevel:.accurate,recognizesMultipleItems:true,isHighlightingEnabled:true)
        vc.delegate = context.coordinator
        try? vc.startScanning()
        return vc
    }
    func updateUIViewController(_ vc: DataScannerViewController, context: Context) {}
    static func dismantleUIViewController(_ vc: DataScannerViewController, coordinator: Coordinator) { vc.stopScanning() }
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onUpdate: ([String]) -> Void
        init(onUpdate: @escaping ([String]) -> Void) { self.onUpdate = onUpdate }
        func dataScanner(_ d: DataScannerViewController, didAdd _: [RecognizedItem], allItems: [RecognizedItem]) { onUpdate(extract(allItems)) }
        func dataScanner(_ d: DataScannerViewController, didUpdate _: [RecognizedItem], allItems: [RecognizedItem]) { onUpdate(extract(allItems)) }
        func dataScanner(_ d: DataScannerViewController, didRemove _: [RecognizedItem], allItems: [RecognizedItem]) { onUpdate(extract(allItems)) }
        private func extract(_ items: [RecognizedItem]) -> [String] {
            items.compactMap { if case .text(let t) = $0 { return t.transcript }; return nil }
        }
    }
}
