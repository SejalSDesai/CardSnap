import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BusinessCard.createdAt, order: .reverse) private var cards: [BusinessCard]
    @State private var showScanner = false
    @State private var searchText  = ""
    @State private var selectedTag: String? = nil

    var allTags: [String] { Array(Set(cards.flatMap { $0.tags })).sorted() }

    var filtered: [BusinessCard] {
        var result = cards
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.company.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText) ||
                $0.jobTitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let tag = selectedTag { result = result.filter { $0.tags.contains(tag) } }
        return result
    }

    var body: some View {
        NavigationStack {
            Group {
                if cards.isEmpty { emptyState } else { cardList }
            }
            .navigationTitle("CardSnap")
            .searchable(text: $searchText, prompt: "Search by name, company...")
            .toolbar {
                if !cards.isEmpty { ToolbarItem(placement: .navigationBarTrailing) { EditButton() } }
                ToolbarItem(placement: .bottomBar) {
                    Button { showScanner = true } label: {
                        Label("Scan Card", systemImage: "camera.viewfinder").font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showScanner) {
                CardScannerSheet { card in modelContext.insert(card) }
            }
        }
    }

    private var cardList: some View {
        List {
            if !allTags.isEmpty {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            TagFilterChip(label: "All", isSelected: selectedTag == nil) { selectedTag = nil }
                            ForEach(allTags, id: \.self) { tag in
                                TagFilterChip(label: tag, isSelected: selectedTag == tag) {
                                    selectedTag = (selectedTag == tag) ? nil : tag
                                }
                            }
                        }.padding(.vertical, 4)
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top:0,leading:12,bottom:0,trailing:12))
            }
            ForEach(filtered) { card in
                NavigationLink(destination: CardDetailView(card: card)) { CardRowView(card: card) }
            }
            .onDelete { offsets in
                for i in offsets { modelContext.delete(filtered[i]) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder").font(.system(size:64)).foregroundColor(.secondary.opacity(0.4))
            Text("No Cards Yet").font(.title2.bold())
            Text("Tap below to scan your first business card.")
                .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center).padding(.horizontal,44)
            Button { showScanner = true } label: {
                Label("Scan a Card", systemImage: "camera").fontWeight(.semibold)
                    .padding(.horizontal,28).padding(.vertical,13)
                    .background(Color.accentColor).foregroundColor(.white).clipShape(Capsule())
            }
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
}

private struct TagFilterChip: View {
    let label: String; let isSelected: Bool; let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            Text(label).font(.caption.weight(.semibold))
                .padding(.horizontal,12).padding(.vertical,6)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.12))
                .foregroundColor(isSelected ? .white : .primary).clipShape(Capsule())
        }.buttonStyle(.plain)
    }
}

private struct CardRowView: View {
    let card: BusinessCard
    var body: some View {
        HStack(spacing:12) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.13)).frame(width:46,height:46)
                Text(initials(for:card.name)).font(.system(size:16,weight:.semibold)).foregroundColor(.accentColor)
            }
            VStack(alignment:.leading,spacing:2) {
                Text(card.name.isEmpty ? "Unknown" : card.name).font(.body.weight(.medium))
                if !card.company.isEmpty { Text(card.company).font(.subheadline).foregroundColor(.secondary) }
                else if !card.jobTitle.isEmpty { Text(card.jobTitle).font(.subheadline).foregroundColor(.secondary) }
                if !card.tags.isEmpty {
                    HStack(spacing:4) {
                        ForEach(card.tags.prefix(3),id:\.self) { tag in
                            Text(tag).font(.caption2.weight(.medium)).padding(.horizontal,6).padding(.vertical,2)
                                .background(Color.accentColor.opacity(0.1)).foregroundColor(.accentColor).clipShape(Capsule())
                        }
                    }.padding(.top,2)
                }
            }
        }.padding(.vertical,2)
    }
    private func initials(for name: String) -> String {
        let p = name.split(separator:" ")
        guard !p.isEmpty else { return "?" }
        if p.count == 1 { return String(p[0].prefix(1)).uppercased() }
        return (String(p[0].prefix(1))+String(p[1].prefix(1))).uppercased()
    }
}
