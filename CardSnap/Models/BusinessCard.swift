// BusinessCard.swift
// CardSnap — SwiftData Model

import Foundation
import SwiftData
import SwiftUI

@Model
class BusinessCard {
    var id: UUID
    var fullName: String
    var email: String?
    var phone: String?
    var company: String?
    var jobTitle: String?
    var website: String?
    var linkedIn: String?
    var twitter: String?
    var address: String?
    var notes: String?
    var rawText: String
    @Attribute(.externalStorage) var imageData: Data?
    var scannedAt: Date
    var isFavorite: Bool
    var tagColor: String  // hex string for per-card accent color

    // MARK: - Init
    init(
        id: UUID = UUID(),
        fullName: String,
        email: String? = nil,
        phone: String? = nil,
        company: String? = nil,
        jobTitle: String? = nil,
        website: String? = nil,
        linkedIn: String? = nil,
        twitter: String? = nil,
        address: String? = nil,
        notes: String? = nil,
        rawText: String = "",
        imageData: Data? = nil,
        scannedAt: Date = .now,
        isFavorite: Bool = false,
        tagColor: String = "#667EEA"
    ) {
        self.id         = id
        self.fullName   = fullName
        self.email      = email
        self.phone      = phone
        self.company    = company
        self.jobTitle   = jobTitle
        self.website    = website
        self.linkedIn   = linkedIn
        self.twitter    = twitter
        self.address    = address
        self.notes      = notes
        self.rawText    = rawText
        self.imageData  = imageData
        self.scannedAt  = scannedAt
        self.isFavorite = isFavorite
        self.tagColor   = tagColor
    }

    // MARK: - Computed: Initials
    var initials: String {
        let parts = fullName
            .components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
        switch parts.count {
        case 0:  return "?"
        case 1:  return String(parts[0].prefix(2)).uppercased()
        default: return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }
    }

    // MARK: - Computed: Display Name
    var displayName: String {
        fullName.isEmpty ? "Unknown" : fullName
    }

    // MARK: - Computed: Subtitle (job @ company)
    var subtitle: String {
        switch (jobTitle, company) {
        case let (j?, c?): return "\(j) @ \(c)"
        case let (j?, nil): return j
        case let (nil, c?): return c
        default: return "No details"
        }
    }

    // MARK: - Computed: Accent Color
    var accentColor: Color {
        Color(hex: tagColor)
    }

    // MARK: - Computed: Formatted Phone
    var formattedPhone: String? {
        guard let phone else { return nil }
        let digits = phone.filter(\.isNumber)
        guard digits.count == 10 else { return phone }
        let area = digits.prefix(3)
        let mid  = digits.dropFirst(3).prefix(3)
        let end  = digits.dropFirst(6)
        return "(\(area)) \(mid)-\(end)"
    }

    // MARK: - Computed: All contact fields for search
    var searchableText: String {
        [fullName, email, phone, company, jobTitle, website, address, notes]
            .compactMap { $0 }
            .joined(separator: " ")
            .lowercased()
    }
}

// MARK: - Tag Colors
extension BusinessCard {
    static let availableTagColors: [(name: String, hex: String)] = [
        ("Purple",  "#667EEA"),
        ("Pink",    "#F093FB"),
        ("Coral",   "#F5576C"),
        ("Green",   "#10B981"),
        ("Amber",   "#F59E0B"),
        ("Sky",     "#38BDF8"),
        ("Indigo",  "#6366F1"),
        ("Rose",    "#FB7185")
    ]
}

// MARK: - Sample Data (for Previews)
extension BusinessCard {
    static var sampleCards: [BusinessCard] {
        [
            BusinessCard(
                fullName: "Alex Johnson",
                email: "alex.johnson@example.com",
                phone: "4155551234",
                company: "Acme Inc.",
                jobTitle: "Senior Product Designer",
                website: "https://alexjohnson.design",
                linkedIn: "linkedin.com/in/alexjohnson",
                scannedAt: Date().addingTimeInterval(-86400 * 3),
                isFavorite: true,
                tagColor: "#667EEA"
            ),
            BusinessCard(
                fullName: "Maria Santos",
                email: "maria@techcorp.io",
                phone: "6502229876",
                company: "TechCorp",
                jobTitle: "CTO",
                website: "https://techcorp.io",
                scannedAt: Date().addingTimeInterval(-86400 * 7),
                isFavorite: false,
                tagColor: "#F093FB"
            ),
            BusinessCard(
                fullName: "David Kim",
                email: "dkim@ventures.vc",
                phone: "3105559001",
                company: "Apex Ventures",
                jobTitle: "Partner",
                website: "https://apexventures.vc",
                scannedAt: Date().addingTimeInterval(-3600),
                isFavorite: true,
                tagColor: "#10B981"
            ),
            BusinessCard(
                fullName: "Priya Patel",
                email: "priya.patel@startup.co",
                phone: "6175554567",
                company: "LaunchPad",
                jobTitle: "Founder & CEO",
                scannedAt: Date(),
                isFavorite: false,
                tagColor: "#F5576C"
            )
        ]
    }
}
