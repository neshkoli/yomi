import SwiftUI
import Foundation

#if os(macOS)
import AppKit
#endif

struct DafYomiHeaderView: View {
    @StateObject private var dataLoader = MasechetDataLoader()
    @Binding var selectedMasechet: Masechet?
    @Binding var selectedDaf: Int
    @Binding var fontSize: CGFloat
    @State private var showSettings = false
    
    // Generate available pages for selected masechet
    private var availablePages: [(number: Int, hebrew: String)] {
        guard let masechet = selectedMasechet else {
            return []
        }
        return HebrewGematria.generatePageList(from: 2, to: masechet.pages + 1)
    }
    
    // Get max page number for current masechet
    private var maxPage: Int {
        guard let masechet = selectedMasechet else {
            return 2
        }
        return masechet.pages + 1
    }
    
    // Get sorted masechtot by order
    private var sortedMasechtot: [Masechet] {
        dataLoader.masechtot.sorted(by: { $0.order < $1.order })
    }
    
    // Get current masechet index in sorted list
    private var currentMasechetIndex: Int? {
        guard let masechet = selectedMasechet else { return nil }
        return sortedMasechtot.firstIndex(where: { $0.id == masechet.id })
    }
    
    // Check if can go to previous page (always true with wrapping)
    private var canGoPrevious: Bool {
        true // Always allow navigation with wrapping
    }
    
    // Check if can go to next page (always true with wrapping)
    private var canGoNext: Bool {
        true // Always allow navigation with wrapping
    }
    
    // Go to previous page with wrapping
    private func goToPreviousPage() {
        guard let masechet = selectedMasechet,
              let currentIndex = currentMasechetIndex else { return }
        
        if selectedDaf > 2 {
            // Within same masechet, just go to previous page
            selectedDaf -= 1
        } else {
            // On first page, go to previous masechet
            if currentIndex > 0 {
                // Go to last page of previous masechet
                let previousMasechet = sortedMasechtot[currentIndex - 1]
                selectedMasechet = previousMasechet
                selectedDaf = previousMasechet.pages + 1 // Last page
            } else {
                // On first masechet, wrap to last page of last masechet
                let lastMasechet = sortedMasechtot[sortedMasechtot.count - 1]
                selectedMasechet = lastMasechet
                selectedDaf = lastMasechet.pages + 1 // Last page
            }
        }
    }
    
    // Go to next page with wrapping
    private func goToNextPage() {
        guard let masechet = selectedMasechet,
              let currentIndex = currentMasechetIndex else { return }
        
        if selectedDaf < maxPage {
            // Within same masechet, just go to next page
            selectedDaf += 1
        } else {
            // On last page, go to next masechet
            if currentIndex < sortedMasechtot.count - 1 {
                // Go to first page of next masechet
                let nextMasechet = sortedMasechtot[currentIndex + 1]
                selectedMasechet = nextMasechet
                selectedDaf = 2 // First page
            } else {
                // On last masechet, wrap to first page of first masechet
                let firstMasechet = sortedMasechtot[0]
                selectedMasechet = firstMasechet
                selectedDaf = 2 // First page
            }
        }
    }
    
    #if os(macOS)
    // Toggle full screen mode
    private func toggleFullScreen() {
        if let window = NSApplication.shared.windows.first {
            window.toggleFullScreen(nil)
        }
    }
    #endif
    
    // Get the date for the currently selected daf
    private var selectedDafDate: Date {
        guard let masechet = selectedMasechet else {
            return Date() // Fallback to today if no masechet selected
        }
        return DafYomiCalculator.calculateDate(for: masechet, daf: selectedDaf, masechtot: dataLoader.masechtot) ?? Date()
    }
    
    // Format standard (Gregorian) date in Hebrew for the selected daf
    private func formatStandardDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "he")
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: date)
    }
    
    // Format Hebrew date for the selected daf
    private func formatHebrewDate(_ date: Date) -> String {
        return HebrewDateFormatter.formatHebrewDate(date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            // Add extra top padding on macOS to account for hidden title bar
            Spacer()
                .frame(height: 8)
            
            // Top line - for double-click to toggle full screen
            HStack {
                Spacer()
            }
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .background(Color(white: 1.0))
            .onTapGesture(count: 2) {
                toggleFullScreen()
            }
            #endif
            
            // Bottom line - controls (dropdowns, buttons)
            ZStack {
                // Background HStack for left and right sections
                HStack(spacing: 0) {
                    // Left section: Settings and navigation buttons
                    HStack(spacing: 12) {
                        // Settings button
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        
                        // Next page button
                        Button(action: goToNextPage) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(canGoNext ? .primary : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoNext)
                        
                        // Previous page button
                        Button(action: goToPreviousPage) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(canGoPrevious ? .primary : .secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .disabled(!canGoPrevious)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    // Right section: Date display
                    HStack(spacing: 12) {
                        // Hebrew date
                        Text(formatHebrewDate(selectedDafDate))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        // Separator
                        Text("•")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        // Standard date
                        Text(formatStandardDate(selectedDafDate))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .multilineTextAlignment(.trailing)
                    .padding(.vertical, 10)
                    .padding(.trailing, 16)
                    .padding(.leading, 12)
                    .environment(\.layoutDirection, .rightToLeft)
                }
                
                // Center section: Dropdowns - overlaid and centered
                HStack(spacing: 12) {
                    // Daf (page) selector
                    if let masechet = selectedMasechet, !availablePages.isEmpty {
                        Menu {
                            ForEach(availablePages, id: \.number) { page in
                                Button(action: {
                                    selectedDaf = page.number
                                }) {
                                    HStack {
                                        if selectedDaf == page.number {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                        Spacer()
                                        Text(page.hebrew)
                                            .font(.system(size: 16))
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .environment(\.layoutDirection, .rightToLeft)
                                }
                            }
                        } label: {
                            Text(HebrewGematria.toHebrew(selectedDaf))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.trailing)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(white: 0.95))
                                .cornerRadius(8)
                        }
                        .menuStyle(.borderlessButton)
                        .environment(\.layoutDirection, .rightToLeft)
                        .fixedSize()
                    }
                    
                    // Masechet selector
                    Menu {
                        ForEach(dataLoader.masechtot) { masechet in
                            Button(action: {
                                selectedMasechet = masechet
                                // Reset daf to 2 when masechet changes
                                selectedDaf = 2
                            }) {
                                HStack {
                                    if let selected = selectedMasechet, selected.id == masechet.id {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                    }
                                    Spacer()
                                    Text(masechet.heTitle)
                                        .font(.system(size: 16))
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity)
                                .environment(\.layoutDirection, .rightToLeft)
                            }
                        }
                    } label: {
                        Text(selectedMasechet?.heTitle ?? "דף יומי היום")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.trailing)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(white: 0.95))
                            .cornerRadius(8)
                    }
                    .menuStyle(.borderlessButton)
                    .environment(\.layoutDirection, .rightToLeft)
                    .fixedSize()
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 16)
            .frame(maxWidth: .infinity)
            .background(Color(white: 1.0))
        }
        .frame(maxWidth: .infinity)
        .background(Color(white: 1.0))
        .ignoresSafeArea(.all, edges: .top)
        .sheet(isPresented: $showSettings) {
            SettingsView(fontSize: $fontSize)
        }
        .onAppear {
            // Select first masechet by default
            if selectedMasechet == nil && !dataLoader.masechtot.isEmpty {
                selectedMasechet = dataLoader.masechtot.first
                selectedDaf = 2
            }
        }
    }
}

#Preview {
    DafYomiHeaderView(selectedMasechet: .constant(nil), selectedDaf: .constant(2), fontSize: .constant(22))
}

