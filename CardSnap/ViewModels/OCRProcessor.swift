// OCRProcessor.swift
// CardSnap — Vision framework OCR + field extraction

import Foundation
import Vision
import UIKit

@MainActor
@Observable
class OCRProcessor {
    var isProcessing = false
    var extractedCard: BusinessCard?
    var errorMessage: String?
    var rawText: String = ""

    // MARK: - Process Image
    func processImage(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil

        guard let cgImage = image.cgImage else {
            errorMessage = "Could not process image."
            isProcessing = false
            return
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        do {
            try handler.perform([request])
            let observations = request.results ?? []
            let lines = observations
                .compactMap { $0.topCandidates(1).first?.string }
            rawText = lines.joined(separator: "\n")
            extractedCard = parseFields(from: lines, imageData: image.jpegData(compressionQuality: 0.8))
        } catch {
            errorMessage = "OCR failed: \(error.localizedDescription)"
        }

        isProcessing = false
    }

    // MARK: - Field Extraction
    private func parseFields(from lines: [String], imageData: Data?) -> BusinessCard {
        var name: String = ""
        var email: String?
        var phone: String?
        var company: String?
        var jobTitle: String?
        var website: String?

        let emailRegex    = try? NSRegularExpression(pattern: #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}"#)
        let phoneRegex    = try? NSRegularExpression(pattern: #"[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}"#)
        let websiteRegex  = try? NSRegularExpression(pattern: #"(https?://|www\.)[^\s]+"#, options: .caseInsensitive)

        let jobKeywords   = ["ceo", "cto", "coo", "cfo", "founder", "co-founder",
                             "president", "vice president", "vp", "director", "manager",
                             "engineer", "developer", "designer", "analyst", "consultant",
                             "partner", "associate", "lead", "head of", "chief", "officer"]

        for (index, line) in lines.enumerated() {
            let lower = line.lowercased()
            let range = NSRange(line.startIndex..., in: line)

            // Email
            if email == nil,
               let match = emailRegex?.firstMatch(in: line, range: range) {
                email = String(line[Range(match.range, in: line)!])
                continue
            }

            // Phone
            if phone == nil,
               let match = phoneRegex?.firstMatch(in: line, range: range) {
                phone = String(line[Range(match.range, in: line)!])
                continue
            }

            // Website
            if website == nil,
               let match = websiteRegex?.firstMatch(in: line, range: range) {
                website = String(line[Range(match.range, in: line)!])
                continue
            }

            // Job title
            if jobTitle == nil,
               jobKeywords.contains(where: { lower.contains($0) }) {
                jobTitle = line
                continue
            }

            // Name heuristic: first short line, no numbers, title case
            if name.isEmpty,
               line.count > 2,
               line.count < 50,
               !line.contains("@"),
               !line.filter(\.isNumber).count.description.isEmpty || line.filter(\.isNumber).isEmpty,
               index < 5 {
                let words = line.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                let looksLikeName = words.allSatisfy { word in
                    guard let first = word.first else { return false }
                    return first.isUppercase || word == word.lowercased()
                }
                if looksLikeName && words.count >= 2 {
                    name = line
                    continue
                }
            }

            // Company: remaining short lines
            if company == nil,
               line.count > 2,
               line.count < 60,
               !line.contains("@"),
               line.filter(\.isNumber).isEmpty || line.filter(\.isNumber).count < 3 {
                company = line
            }
        }

        if name.isEmpty {
            name = lines.first(where: { !$0.isEmpty && $0.count > 2 }) ?? "Unknown"
        }

        return BusinessCard(
            fullName:  name,
            email:     email,
            phone:     phone,
            company:   company,
            jobTitle:  jobTitle,
            website:   website,
            rawText:   lines.joined(separator: "\n"),
            imageData: imageData
        )
    }
}
