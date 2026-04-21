# CardSnap — Setup Guide

## Requirements
- Xcode 15+
- iOS 17+ deployment target
- Swift 5.9+

## Project Setup in Xcode

1. **Create a new Xcode project**
   - File → New → Project
   - Choose **iOS → App**
   - Product Name: `CardSnap`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData** ✓

2. **Add all source files**
   Copy the entire `CardSnap/` folder structure into your project. The layout:
   ```
   CardSnap/
   ├── CardSnapApp.swift
   ├── Info.plist
   ├── Models/
   │   └── BusinessCard.swift
   ├── Extensions/
   │   ├── Color+Extensions.swift
   │   └── View+Extensions.swift
   ├── ViewModels/
   │   └── OCRProcessor.swift
   └── Views/
       ├── ContentView.swift
       ├── Home/
       │   ├── HomeView.swift
       │   ├── CardRowView.swift
       │   ├── FavoritesView.swift
       │   └── SettingsView.swift
       ├── Scan/
       │   └── ScanView.swift
       ├── Detail/
       │   ├── CardDetailView.swift
       │   └── EditCardView.swift
       └── Components/
           ├── AvatarView.swift
           ├── AnimatedGradientBackground.swift
           ├── EmptyStateView.swift
           ├── GradientCardView.swift
           └── ContactActionButton.swift
   ```

3. **Add Frameworks** (in Xcode → Target → Frameworks)
   - `Vision.framework` — OCR text recognition
   - `VisionKit.framework` — Document camera scanner
   - `Contacts.framework` — Export to Contacts app

4. **Configure Info.plist**
   Merge the provided `Info.plist` entries into your project's Info.plist (or set them via Target → Info tab):
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSContactsUsageDescription`

5. **Build & Run**
   - Select an iOS 17 simulator or physical device
   - ⌘R to build and run

## Key Features

| Feature | Implementation |
|---------|----------------|
| OCR scanning | Vision `VNRecognizeTextRequest` |
| Document camera | VisionKit `VNDocumentCameraViewController` |
| Data persistence | SwiftData `@Model` |
| Animations | SwiftUI `.spring()`, `symbolEffect` |
| Dark mode | `.preferredColorScheme(.dark)` |
| Contacts export | `CNMutableContact` + `CNSaveRequest` |
| Photo import | `PhotosPicker` |
| Haptics | `UIImpactFeedbackGenerator` |

## Architecture

- **Models**: SwiftData `@Model` class — `BusinessCard`
- **ViewModels**: `OCRProcessor` (`@Observable`) handles Vision OCR
- **Views**: Pure SwiftUI, environment-injected model context
- **Design System**: `Color+Extensions`, `View+Extensions` with reusable modifiers

## Notes

- The app defaults to **dark mode** — change in `CardSnapApp.swift`
- OCR field extraction uses regex + heuristics and works best on clean, standard business card layouts
- The `@Attribute(.externalStorage)` on `imageData` keeps SwiftData store small
