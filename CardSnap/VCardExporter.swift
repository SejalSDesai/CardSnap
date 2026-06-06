import Foundation

enum VCardExporter {
    static func vcardString(for card: BusinessCard) -> String {
        var lines = ["BEGIN:VCARD","VERSION:3.0"]
        let parts = card.name.split(separator:" ")
        lines.append("N:\(parts.dropFirst().joined(separator:" "));\(parts.first.map(String.init) ?? card.name);;;")
        lines.append("FN:\(card.name)")
        if !card.company.isEmpty  { lines.append("ORG:\(card.company)") }
        if !card.jobTitle.isEmpty { lines.append("TITLE:\(card.jobTitle)") }
        if !card.email.isEmpty    { lines.append("EMAIL;TYPE=WORK:\(card.email)") }
        if !card.phone.isEmpty    { lines.append("TEL;TYPE=WORK:\(card.phone)") }
        if !card.website.isEmpty  { lines.append("URL:\(card.website)") }
        if !card.address.isEmpty  { lines.append("ADR;TYPE=WORK:;;\(card.address);;;;") }
        if !card.notes.isEmpty    { lines.append("NOTE:\(card.notes)") }
        if !card.tags.isEmpty     { lines.append("CATEGORIES:\(card.tags.joined(separator:","))") }
        lines.append("END:VCARD")
        return lines.joined(separator:"\r\n")
    }
    static func vcardFileURL(for card: BusinessCard) -> URL {
        let name = card.name.isEmpty ? "contact" : card.name.replacingOccurrences(of:" ",with:"_")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).vcf")
        try? vcardString(for:card).write(to:url,atomically:true,encoding:.utf8)
        return url
    }
}
