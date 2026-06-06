import SwiftUI
private let presetTags = ["Client","Colleague","Conference","Friend","Recruiter","Vendor"]

struct CardEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var card: BusinessCard
    let isNew: Bool
    let onSave: (BusinessCard) -> Void
    @State private var newTag = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Contact") {
                    FieldRow("Name",      text:$card.name,     icon:"person",     keyboard:.default)
                    FieldRow("Job Title", text:$card.jobTitle, icon:"briefcase",  keyboard:.default)
                    FieldRow("Company",   text:$card.company,  icon:"building.2", keyboard:.default)
                }
                Section("Details") {
                    FieldRow("Email",   text:$card.email,   icon:"envelope", keyboard:.emailAddress)
                    FieldRow("Phone",   text:$card.phone,   icon:"phone",    keyboard:.phonePad)
                    FieldRow("Website", text:$card.website, icon:"globe",    keyboard:.URL)
                    FieldRow("Address", text:$card.address, icon:"mappin",   keyboard:.default)
                }
                Section("Tags") {
                    LazyVGrid(columns:[GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())],spacing:8) {
                        ForEach(allTags,id:\.self) { tag in
                            let sel = card.tags.contains(tag)
                            Button {
                                if sel { card.tags.removeAll{$0==tag} } else { card.tags.append(tag) }
                            } label: {
                                Text(tag).font(.caption.weight(.medium)).frame(maxWidth:.infinity).padding(.vertical,6)
                                    .background(sel ? Color.accentColor : Color.secondary.opacity(0.1))
                                    .foregroundColor(sel ? .white : .primary).clipShape(Capsule())
                            }.buttonStyle(.plain)
                        }
                    }.padding(.vertical,4)
                    HStack {
                        TextField("Add custom tag...", text:$newTag).autocorrectionDisabled().textInputAutocapitalization(.words)
                        Button("Add") {
                            let t = newTag.trimmingCharacters(in:.whitespaces)
                            if !t.isEmpty && !card.tags.contains(t) { card.tags.append(t) }
                            newTag = ""
                        }.disabled(newTag.trimmingCharacters(in:.whitespaces).isEmpty)
                    }
                }
                Section("Notes") { TextEditor(text:$card.notes).frame(minHeight:80) }
            }
            .navigationTitle(isNew ? "New Card" : "Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement:.cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement:.confirmationAction) {
                    Button("Save") { onSave(card) }.fontWeight(.semibold)
                        .disabled(card.name.trimmingCharacters(in:.whitespaces).isEmpty)
                }
            }
        }
    }
    private var allTags: [String] { presetTags + card.tags.filter{!presetTags.contains($0)} }
}

private struct FieldRow: View {
    let label: String; @Binding var text: String; let icon: String; let keyboard: UIKeyboardType
    init(_ label:String,text:Binding<String>,icon:String,keyboard:UIKeyboardType) {
        self.label=label; self._text=text; self.icon=icon; self.keyboard=keyboard
    }
    var body: some View {
        HStack(spacing:10) {
            Image(systemName:icon).foregroundColor(.secondary).frame(width:20)
            TextField(label,text:$text).keyboardType(keyboard)
                .autocorrectionDisabled(keyboard != .default)
                .textInputAutocapitalization((keyboard == .emailAddress || keyboard == .URL) ? .never : .words)
        }
    }
}
