import SwiftUI

#if os(macOS)
import AppKit
#endif

@main
struct NehardeaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .background(Color(white: 1.0).ignoresSafeArea(.all, edges: .all))
                #if os(macOS)
                .frame(minWidth: 1200, minHeight: 800)
                .background(WindowAccessor())
                #endif
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .defaultSize(width: 1400, height: 900)
        #endif
    }
}

#if os(macOS)
// Helper view to access and configure NSWindow
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                // Enable standard title bar for double-click to maximize
                window.titlebarAppearsTransparent = false
                window.titleVisibility = .visible
                window.styleMask.insert(.resizable)
                window.styleMask.insert(.titled)
                window.styleMask.remove(.fullSizeContentView)
                
                // Set initial title
                window.title = "Nehardea"
                
                // Ensure window can be maximized (no maxSize restriction)
                window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// Helper function to update window title
func setMacWindowTitle(_ title: String) {
    DispatchQueue.main.async {
        if let window = NSApplication.shared.windows.first {
            window.title = title
        }
    }
}
#endif

