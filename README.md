# Daf Yomi Viewer

A SwiftUI iPad application for viewing the daily Daf Yomi (Talmud learning) with a three-panel layout.

## Features

- Three-panel layout:
  - Main Talmud text (right panel)
  - Rashi commentary (top left)
  - Steinsaltz commentary (bottom left)
- Draggable dividers to adjust panel sizes
- Full screen support
- Portrait and landscape orientation support
- Hebrew text with RTL support

## Project Structure

```
DafYomiViewer/
├── DafYomiViewerApp.swift      # App entry point
├── ContentView.swift            # Main layout
├── Views/
│   ├── DafYomiHeaderView.swift  # Header component
│   ├── TextPanelView.swift      # Text panel component
│   └── DraggableDivider.swift   # Draggable divider
├── Models/
│   └── DafYomiData.swift        # Data models (placeholders)
└── Info.plist                   # App configuration
```

## Setup

1. Open the project in Xcode
2. Configure the project for iPad deployment
3. Build and run

## Future Enhancements

- Sefaria API integration for fetching Daf Yomi content
- Date calculation for today's Daf Yomi
- Caching for offline viewing
- Mac and iPhone support

