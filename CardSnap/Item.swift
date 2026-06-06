import Foundation
import SwiftData

@Model
final class BusinessCard {
    var name: String
    var jobTitle: String
    var company: String
    var email: String
    var phone: String
    var website: String
    var address: String
    var notes: String
    var createdAt: Date
    var imageData: Data?
    var tags: [String]

    init(name: String = "", jobTitle: String = "", company: String = "",
         email: String = "", phone: String = "", website: String = "",
         address: String = "", notes: String = "", tags: [String] = []) {
        self.name = name; self.jobTitle = jobTitle; self.company = company
        self.email = email; self.phone = phone; self.website = website
        self.address = address; self.notes = notes
        self.createdAt = Date(); self.tags = tags
    }
}
