import SwiftUI

struct ContentView: View {
    // Panel size ratios (0.0 to 1.0)
    @State private var leftPanelWidth: CGFloat = 0.4  // 40% of screen width
    @State private var rashiHeight: CGFloat = 0.5    // 50% of left panel height
    
    // Minimum panel sizes (as ratios)
    private let minPanelWidth: CGFloat = 0.2   // 20% minimum
    private let maxPanelWidth: CGFloat = 0.8   // 80% maximum
    private let minPanelHeight: CGFloat = 0.2  // 20% minimum
    private let maxPanelHeight: CGFloat = 0.8  // 80% maximum
    
    private let headerHeight: CGFloat = 70
    
    @StateObject private var contentLoader = MasechetContentLoader()
    @State private var selectedMasechet: Masechet?
    @State private var selectedDaf: Int = 2
    @State private var fontSize: CGFloat = 22
    
    // Reload content when selection changes
    private func reloadContent() {
        if let masechet = selectedMasechet {
            contentLoader.loadMasechet(masechet.title)
        }
    }
    
    // Get content for current selection
    private func getGemaraText() -> String {
        guard let masechet = selectedMasechet else { return "" }
        
        // Load content if not already loaded or if masechet changed
        if contentLoader.content == nil || contentLoader.content?.title != masechet.title {
            reloadContent()
            return "" // Return empty while loading
        }
        
        // Get both parts (a and b) and combine them
        let partA = contentLoader.getDafContent(page: selectedDaf, part: "a") ?? []
        let partB = contentLoader.getDafContent(page: selectedDaf, part: "b") ?? []
        
        var combinedText = ""
        
        // Combine all gemara from part A, wrapping each in <p> tags
        for content in partA {
            if !combinedText.isEmpty {
                combinedText += "\n"
            }
            combinedText += "<p>" + content.gemara + "</p>"
        }
        
        // Combine all gemara from part B, wrapping each in <p> tags
        for content in partB {
            if !combinedText.isEmpty {
                combinedText += "\n"
            }
            combinedText += "<p>" + content.gemara + "</p>"
        }
        
        return combinedText
    }
    
    private func getRashiText() -> String {
        guard let masechet = selectedMasechet else { return "" }
        
        let partA = contentLoader.getDafContent(page: selectedDaf, part: "a") ?? []
        let partB = contentLoader.getDafContent(page: selectedDaf, part: "b") ?? []
        
        var combinedText = ""
        
        for content in partA {
            for rashi in content.rashi {
                if !combinedText.isEmpty {
                    combinedText += "\n"
                }
                combinedText += "<p>" + rashi + "</p>"
            }
        }
        
        for content in partB {
            for rashi in content.rashi {
                if !combinedText.isEmpty {
                    combinedText += "\n"
                }
                combinedText += "<p>" + rashi + "</p>"
            }
        }
        
        return combinedText
    }
    
    private func getSteinsaltzText() -> String {
        guard let masechet = selectedMasechet else { return "" }
        
        let partA = contentLoader.getDafContent(page: selectedDaf, part: "a") ?? []
        let partB = contentLoader.getDafContent(page: selectedDaf, part: "b") ?? []
        
        var combinedText = ""
        
        for content in partA {
            for steinsaltz in content.steinsaltz {
                if !combinedText.isEmpty {
                    combinedText += "\n"
                }
                combinedText += "<p>" + steinsaltz + "</p>"
            }
        }
        
        for content in partB {
            for steinsaltz in content.steinsaltz {
                if !combinedText.isEmpty {
                    combinedText += "\n"
                }
                combinedText += "<p>" + steinsaltz + "</p>"
            }
        }
        
        return combinedText
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - headerHeight
            
            ZStack {
                // Background to fill entire screen
                Color(white: 1.0)
                    .opacity(1.0)
                    .ignoresSafeArea(.all, edges: .all)
                
                VStack(spacing: 0) {
                    // Header
                    DafYomiHeaderView(selectedMasechet: $selectedMasechet, selectedDaf: $selectedDaf, fontSize: $fontSize)
                    
                    // Main content area
                    HStack(spacing: 0) {
                        // Left panel (Rashi and Steinsaltz)
                        VStack(spacing: 0) {
                            // Rashi panel
                            TextPanelView(
                                title: "רש\"י",
                                content: getRashiText(),
                                fontSize: fontSize
                            )
                            .frame(height: availableHeight * rashiHeight)
                            
                            // Horizontal divider
                            DraggableDivider(orientation: .horizontal) { delta in
                                let newHeight = rashiHeight + (delta / availableHeight)
                                rashiHeight = min(max(newHeight, minPanelHeight), maxPanelHeight)
                            }
                            
                            // Steinsaltz panel
                            TextPanelView(
                                title: "שטיינזלץ",
                                content: getSteinsaltzText(),
                                fontSize: fontSize
                            )
                            .frame(height: availableHeight * (1.0 - rashiHeight))
                        }
                        .frame(width: geometry.size.width * leftPanelWidth)
                        
                        // Vertical divider
                        DraggableDivider(orientation: .vertical) { delta in
                            let newWidth = leftPanelWidth + (delta / geometry.size.width)
                            leftPanelWidth = min(max(newWidth, minPanelWidth), maxPanelWidth)
                        }
                        
                        // Right panel (Main Talmud text)
                        TextPanelView(
                            title: "גמרא",
                            content: getGemaraText(),
                            fontSize: fontSize
                        )
                        .frame(width: geometry.size.width * (1.0 - leftPanelWidth))
                    }
                    .frame(height: availableHeight)
                }
            }
        }
        .ignoresSafeArea(.all, edges: .all)
        .onChange(of: selectedMasechet) { _ in
            reloadContent()
        }
        .onChange(of: selectedDaf) { _ in
            // Content will be reloaded automatically when accessed
        }
    }
}

#Preview {
    ContentView()
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        .previewInterfaceOrientation(.landscapeLeft)
}

