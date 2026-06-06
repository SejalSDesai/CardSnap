import Foundation

enum CardParser {
    static func parse(_ lines: [String]) -> BusinessCard {
        let card = BusinessCard()
        var unused: [String] = []
        for raw in lines {
            let line = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            if card.email.isEmpty, let v = firstMatch(#"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"#, in: line) { card.email = v }
            else if card.phone.isEmpty, let v = firstMatch(#"[\+]?[(]?[0-9]{1,4}[)]?[-\s\./0-9]{6,14}"#, in: line) { card.phone = v }
            else if card.website.isEmpty, let v = firstMatch(#"(https?://|www\.)\S+"#, in: line) { card.website = v }
            else { unused.append(line) }
        }
        if let name = unused.sorted(by: { $0.count > $1.count }).first { card.name = name }
        let rest = unused.filter { $0 != card.name }
        if rest.count > 0 { card.jobTitle = rest[0] }
        if rest.count > 1 { card.company  = rest[1] }
        return card
    }
    private static func firstMatch(_ pattern: String, in text: String) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let ns = text as NSString
        guard let m = re.firstMatch(in: text, range: NSRange(location:0,length:ns.length)) else { return nil }
        return ns.substring(with: m.range)
    }
}
