import SwiftUI
import SwiftData
import Contacts

struct CardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let card: BusinessCard
    @State private var showEdit  = false
    @State private var alert: AlertInfo? = nil
    @State private var shareURL: URL? = nil
    @State private var showShare = false

    struct AlertInfo: Identifiable {
        let id = UUID(); let title: String; let message: String
    }

    var body: some View {
        List {
            Section {
                VStack(spacing:6) {
                    ZStack {
                        Circle().fill(Color.accentColor.opacity(0.12)).frame(width:72,height:72)
                        Text(initials(for:card.name)).font(.system(size:26,weight:.semibold)).foregroundColor(.accentColor)
                    }
                    Text(card.name.isEmpty ? "No Name" : card.name).font(.title3.bold())
                    if !card.jobTitle.isEmpty { Text(card.jobTitle).font(.subheadline).foregroundColor(.secondary) }
                    if !card.company.isEmpty  { Text(card.company).font(.subheadline).foregroundColor(.secondary) }
                    if !card.tags.isEmpty {
                        ScrollView(.horizontal,showsIndicators:false) {
                            HStack(spacing:6) {
                                ForEach(card.tags,id:\.self) { tag in
                                    Text(tag).font(.caption.weight(.medium)).padding(.horizontal,10).padding(.vertical,4)
                                        .background(Color.accentColor.opacity(0.1)).foregroundColor(.accentColor).clipShape(Capsule())
                                }
                            }
                        }.padding(.top,4)
                    }
                }.frame(maxWidth:.infinity).padding(.vertical,10)
            }
            if !card.email.isEmpty || !card.phone.isEmpty || !card.website.isEmpty {
                Section("Contact") {
                    if !card.email.isEmpty {
                        ActionRow(icon:"envelope.fill",color:.blue,label:card.email) { open("mailto:\(card.email)") }
                    }
                    if !card.phone.isEmpty {
                        ActionRow(icon:"phone.fill",color:.green,label:card.phone) {
                            open("tel:\(card.phone.filter{$0.isNumber||$0=="+"})")
                        }
                    }
                    if !card.website.isEmpty {
                        ActionRow(icon:"globe",color:.orange,label:card.website) {
                            open(card.website.hasPrefix("http") ? card.website : "https://\(card.website)")
                        }
                    }
                }
            }
            if !card.address.isEmpty { Section("Address") { Label(card.address,systemImage:"mappin.and.ellipse") } }
            if !card.notes.isEmpty   { Section("Notes")   { Text(card.notes).foregroundColor(.secondary) } }
            Section {
                Button { shareURL = VCardExporter.vcardFileURL(for:card); showShare = true } label: {
                    Label("Share Card",systemImage:"square.and.arrow.up")
                }
                Button { Task { await saveToContacts() } } label: {
                    Label("Save to Contacts",systemImage:"person.crop.circle.badge.plus")
                }
                Button(role:.destructive) { modelContext.delete(card); dismiss() } label: {
                    Label("Delete Card",systemImage:"trash")
                }
            }
        }
        .navigationTitle(card.name.isEmpty ? "Card" : card.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement:.navigationBarTrailing) { Button("Edit") { showEdit = true } } }
        .sheet(isPresented:$showEdit) { CardEditView(card:card,isNew:false) { _ in showEdit = false } }
        .sheet(isPresented:$showShare) { if let url = shareURL { ShareSheet(items:[url]).ignoresSafeArea() } }
        .alert(item:$alert) { info in Alert(title:Text(info.title),message:Text(info.message),dismissButton:.default(Text("OK"))) }
    }

    private func open(_ s: String) { if let u = URL(string:s) { UIApplication.shared.open(u) } }
    private func initials(for name: String) -> String {
        let p = name.split(separator:" ")
        guard !p.isEmpty else { return "?" }
        if p.count==1 { return String(p[0].prefix(1)).uppercased() }
        return (String(p[0].prefix(1))+String(p[1].prefix(1))).uppercased()
    }
    private func saveToContacts() async {
        let store = CNContactStore()
        do {
            guard try await store.requestAccess(for:.contacts) else {
                alert = AlertInfo(title:"Access Denied",message:"Enable Contacts access in Settings."); return
            }
            let c = CNMutableContact()
            let p = card.name.split(separator:" ")
            c.givenName = p.first.map(String.init) ?? card.name
            c.familyName = p.dropFirst().joined(separator:" ")
            c.jobTitle = card.jobTitle; c.organizationName = card.company
            if !card.email.isEmpty   { c.emailAddresses = [CNLabeledValue(label:CNLabelWork,value:card.email as NSString)] }
            if !card.phone.isEmpty   { c.phoneNumbers   = [CNLabeledValue(label:CNLabelWork,value:CNPhoneNumber(stringValue:card.phone))] }
            if !card.website.isEmpty { c.urlAddresses   = [CNLabeledValue(label:CNLabelWork,value:card.website as NSString)] }
            let req = CNSaveRequest(); req.add(c,toContainerWithIdentifier:nil)
            try store.execute(req)
            alert = AlertInfo(title:"Saved",message:"\(card.name) added to your Contacts.")
        } catch { alert = AlertInfo(title:"Error",message:error.localizedDescription) }
    }
}

private struct ActionRow: View {
    let icon: String; let color: Color; let label: String; let action: () -> Void
    var body: some View {
        Button(action:action) {
            HStack(spacing:12) {
                ZStack {
                    RoundedRectangle(cornerRadius:7).fill(color).frame(width:30,height:30)
                    Image(systemName:icon).foregroundColor(.white).font(.system(size:13,weight:.semibold))
                }
                Text(label).foregroundColor(.primary); Spacer()
                Image(systemName:"arrow.up.right").font(.caption).foregroundColor(.secondary.opacity(0.5))
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context:Context) -> UIActivityViewController {
        UIActivityViewController(activityItems:items,applicationActivities:nil)
    }
    func updateUIViewController(_ vc:UIActivityViewController,context:Context) {}
}
