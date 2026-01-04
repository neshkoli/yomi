import SwiftUI

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
    
    // Check if can go to previous page
    private var canGoPrevious: Bool {
        selectedDaf > 2
    }
    
    // Check if can go to next page
    private var canGoNext: Bool {
        selectedDaf < maxPage
    }
    
    // Go to previous page
    private func goToPreviousPage() {
        if canGoPrevious {
            selectedDaf -= 1
        }
    }
    
    // Go to next page
    private func goToNextPage() {
        if canGoNext {
            selectedDaf += 1
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
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            // Add extra top padding on macOS to account for hidden title bar
            Spacer()
                .frame(height: 8)
            #endif
            
            // Top line - for double-click to toggle full screen
            HStack {
                Spacer()
            }
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .background(Color(white: 1.0))
            #if os(macOS)
            .onTapGesture(count: 2) {
                toggleFullScreen()
            }
            #endif
            
            // Bottom line - controls (dropdowns, buttons)
            HStack(spacing: 12) {
                // Settings button - at the most left
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
                
                Spacer()
                
                // Next page button (swapped position - now first)
                Button(action: goToNextPage) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoNext ? .primary : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .disabled(!canGoNext)
                
                // Previous page button (swapped position - now second)
                Button(action: goToPreviousPage) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(canGoPrevious ? .primary : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .disabled(!canGoPrevious)
                
                // Daf (page) selector - positioned to the left of masechet
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
                
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color(white: 1.0))
        }
        .frame(height: 70)
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

