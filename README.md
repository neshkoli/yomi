# Daf Yomi Viewer

A SwiftUI application for viewing the daily Daf Yomi (Talmud learning) with a multi-panel layout. Available for iPad and macOS.

## Features

- **Multi-panel layout:**
  - Main Talmud text (Gemara)
  - Rashi commentary
  - Steinsaltz commentary
  - Adaptive layout for portrait and landscape orientations on iPad
- **Daf Yomi calculation:**
  - Automatically calculates today's Daf Yomi based on the current cycle (starting January 5, 2020)
  - Navigate between dafs with date synchronization
  - Supports all 40 masechtot (tractates) with accurate page counts
- **Date display:**
  - Hebrew calendar date (full format)
  - Gregorian date in Hebrew
  - Dates update when navigating between dafs
- **User interface:**
  - Draggable dividers to adjust panel sizes
  - Full screen support (macOS)
  - Hebrew text with RTL support
  - Customizable font size
  - Optimized padding for RTL text flow
- **Platforms:**
  - iPad (portrait and landscape)
  - macOS

## Project Structure

```
DafYomiViewer/
├── DafYomiViewerApp.swift      # App entry point
├── ContentView.swift            # Main layout with orientation handling
├── Views/
│   ├── DafYomiHeaderView.swift  # Header with navigation and date display
│   ├── TextPanelView.swift      # Text panel component with WKWebView
│   ├── DraggableDivider.swift   # Draggable divider for resizing panels
│   └── SettingsView.swift      # Settings panel for font size
├── Models/
│   └── DafYomiData.swift       # Data models, Hebrew date formatter, Daf Yomi calculator
└── sources/
    └── masechet.json            # Masechtot data with page counts
```

## Setup

1. Open the project in Xcode
2. Select the target (DafYomiViewer for iPad or DafYomiViewerMac for macOS)
3. Build and run

## Daf Yomi Cycle

The app uses the Daf Yomi cycle that started on January 5, 2020 (Cycle 14). The cycle length is 2,711 days, covering all 40 masechtot with a total of 2,711 pages.

## Technical Details

- **Hebrew Date Calculation:** Uses native Swift `Calendar(identifier: .hebrew)` and `DateFormatter` with Hebrew locale
- **Hebrew Gematria:** Custom converter for displaying page numbers in Hebrew numerals
- **Layout:** Adaptive layout using `GeometryReader` and orientation detection
- **Text Rendering:** `WKWebView` for HTML rendering with RTL support and custom padding

## Future Enhancements

- Sefaria API integration for fetching actual Daf Yomi content
- Caching for offline viewing
- iPhone support
- Search functionality
- Bookmarking favorite dafs

