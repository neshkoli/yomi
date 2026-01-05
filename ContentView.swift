import SwiftUI

#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    // Panel size ratios (0.0 to 1.0)
    @State private var leftPanelWidth: CGFloat = 0.4  // 40% of screen width
    @State private var rashiHeight: CGFloat = 0.5    // 50% of left panel height
    
    // Portrait mode panel sizes
    @State private var gemaraHeight: CGFloat = 0.5    // 50% of available height for Gemara (top)
    @State private var bottomLeftWidth: CGFloat = 0.5  // 50% of width for Steinsaltz (left in bottom)
    
    // Minimum panel sizes (as ratios)
    private let minPanelWidth: CGFloat = 0.2   // 20% minimum
    private let maxPanelWidth: CGFloat = 0.8   // 80% maximum
    private let minPanelHeight: CGFloat = 0.2  // 20% minimum
    private let maxPanelHeight: CGFloat = 0.8  // 80% maximum
    
    private let headerHeight: CGFloat = 70
    
    @StateObject private var contentLoader = MasechetContentLoader()
    @StateObject private var masechetDataLoader = MasechetDataLoader()
    @State private var selectedMasechet: Masechet?
    @State private var selectedDaf: Int = 2
    @State private var fontSize: CGFloat = 22
    
    // Reload content when selection changes
    private func reloadContent() {
        if let masechet = selectedMasechet {
            contentLoader.loadMasechet(masechet.title)
        }
    }
    
    #if os(macOS)
    // Update window title with masechet name and daf
    private func updateWindowTitle() {
        if let masechet = selectedMasechet {
            let dafHebrew = HebrewGematria.toHebrew(selectedDaf)
            let title = "\(masechet.heTitle) \(dafHebrew)"
            setMacWindowTitle(title)
        } else {
            setMacWindowTitle("Daf Yomi Viewer")
        }
    }
    #endif
    
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
            let isLandscape = geometry.size.width > geometry.size.height
            #if os(iOS)
            let isIPad = UIDevice.current.userInterfaceIdiom == .pad
            #else
            let isIPad = false
            #endif
            
            // Use full geometry height (including safe areas)
            let fullHeight = geometry.size.height
            let availableHeight = fullHeight - headerHeight
            
            ZStack {
                // Background to fill entire screen including safe areas
                Color(white: 1.0)
                    .ignoresSafeArea(.all, edges: .all)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                
                VStack(spacing: 0) {
                    // Header - background extends to top, content respects safe area
                    DafYomiHeaderView(selectedMasechet: $selectedMasechet, selectedDaf: $selectedDaf, fontSize: $fontSize)
                        .frame(height: headerHeight)
                        .background(Color(white: 1.0).ignoresSafeArea(.all, edges: .top))
                    
                    // Main content area - different layout for iPad portrait
                    if isIPad && !isLandscape {
                        // Portrait layout: Top half Gemara, bottom half split Rashi/Steinsaltz
                        VStack(spacing: 0) {
                            // Top half: Gemara (full width)
                            TextPanelView(
                                title: "גמרא",
                                content: getGemaraText(),
                                fontSize: fontSize
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: availableHeight * gemaraHeight)
                            
                            // Horizontal divider
                            DraggableDivider(orientation: .horizontal) { delta in
                                let newHeight = gemaraHeight + (delta / availableHeight)
                                gemaraHeight = min(max(newHeight, minPanelHeight), maxPanelHeight)
                            }
                            
                            // Bottom half: Rashi and Steinsaltz side by side
                            HStack(spacing: 0) {
                                // Steinsaltz (left)
                                TextPanelView(
                                    title: "שטיינזלץ",
                                    content: getSteinsaltzText(),
                                    fontSize: fontSize
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(width: geometry.size.width * bottomLeftWidth)
                                
                                // Vertical divider
                                DraggableDivider(orientation: .vertical) { delta in
                                    let newWidth = bottomLeftWidth + (delta / geometry.size.width)
                                    bottomLeftWidth = min(max(newWidth, minPanelWidth), maxPanelWidth)
                                }
                                
                                // Rashi (right)
                                TextPanelView(
                                    title: "רש\"י",
                                    content: getRashiText(),
                                    fontSize: fontSize
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(width: geometry.size.width * (1.0 - bottomLeftWidth))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(height: availableHeight * (1.0 - gemaraHeight))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Landscape layout (or non-iPad): Original layout
                        HStack(spacing: 0) {
                            // Left panel (Rashi and Steinsaltz)
                            VStack(spacing: 0) {
                                // Rashi panel
                                TextPanelView(
                                    title: "רש\"י",
                                    content: getRashiText(),
                                    fontSize: fontSize
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .frame(height: availableHeight * (1.0 - rashiHeight))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .frame(width: geometry.size.width * (1.0 - leftPanelWidth))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(height: availableHeight)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .ignoresSafeArea(.all, edges: .all)
        .background(Color(white: 1.0).ignoresSafeArea(.all, edges: .all))
        .onAppear {
            // Calculate and set today's daf when app appears
            if selectedMasechet == nil && !masechetDataLoader.masechtot.isEmpty {
                if let todayDaf = DafYomiCalculator.calculateTodayDaf(masechtot: masechetDataLoader.masechtot) {
                    selectedMasechet = todayDaf.masechet
                    selectedDaf = todayDaf.daf
                } else {
                    // Fallback to first masechet if calculation fails
                    selectedMasechet = masechetDataLoader.masechtot.first
                    selectedDaf = 2
                }
            }
            #if os(macOS)
            updateWindowTitle()
            #endif
        }
        .onChange(of: selectedMasechet) { _ in
            reloadContent()
            #if os(macOS)
            updateWindowTitle()
            #endif
        }
        .onChange(of: selectedDaf) { _ in
            // Content will be reloaded automatically when accessed
            #if os(macOS)
            updateWindowTitle()
            #endif
        }
    }
}

#Preview {
    ContentView()
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        .previewInterfaceOrientation(.landscapeLeft)
}

