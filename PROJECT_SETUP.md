# Project Setup Instructions

## Creating the Xcode Project

1. Open Xcode
2. Create a new project:
   - Choose "App" template
   - Product Name: `Nehardea`
   - Interface: SwiftUI
   - Language: Swift
   - Platforms: iPad (you can add Mac and iPhone later)

3. Add the existing files to the project:
   - Drag the `Views` folder into the project
   - Drag the `Models` folder into the project
   - Replace the default `ContentView.swift` with the one in this directory
   - Replace the default `NehardeaApp.swift` (or `App.swift`) with the one in this directory

4. Configure the project:
   - In Project Settings → General:
   - Set "Supported Destinations" to iPad
   - Under "Deployment Info", ensure all orientations are enabled
   - In Project Settings → Info:
   - Add the settings from `Info.plist` if not already present
   - Ensure `UIRequiresFullScreen` is set to `YES`

5. Build and run the project

## File Structure

The project should have this structure:

```
Nehardea/
├── NehardeaApp.swift
├── ContentView.swift
├── Views/
│   ├── DafYomiHeaderView.swift
│   ├── TextPanelView.swift
│   └── DraggableDivider.swift
└── Models/
    └── DafYomiData.swift
```

## Testing

- Test in both portrait and landscape orientations
- Verify that the draggable dividers work correctly
- Check that Hebrew text displays properly with RTL support
