import SwiftUI
import WebKit

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct TextPanelView: View {
    let title: String
    let content: String
    var fontSize: CGFloat = 22
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Title bar
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                Spacer()
            }
            .background(Color(white: 0.95))
            
            // Content area using WKWebView for full HTML support including images
            if content.isEmpty {
                ScrollView {
                    HStack {
                        Spacer()
                        Text("טקסט לא זמין")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HTMLWebView(htmlContent: content, fontSize: fontSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 1.0))
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// Platform-agnostic wrapper for WKWebView with full HTML support
#if os(iOS)
struct HTMLWebView: UIViewRepresentable {
    let htmlContent: String
    var fontSize: CGFloat = 22
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        webView.scrollView.backgroundColor = .systemBackground
        // Increased padding for better spacing from edges on iPad
        // For RTL text, more padding on right (where text starts) and minimal on left (where text ends)
        let rightPadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24
        let leftPadding: CGFloat = 8  // Minimal padding on left side for RTL
        let topPadding: CGFloat = 8  // Reduced top padding
        let bottomPadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20
        webView.scrollView.contentInset = UIEdgeInsets(top: topPadding, left: leftPadding, bottom: bottomPadding, right: rightPadding)
        webView.scrollView.isScrollEnabled = true
        webView.semanticContentAttribute = .forceRightToLeft
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update when content or fontSize changes
        updateWebView(webView)
    }
    
    private func updateWebView(_ webView: WKWebView) {
        let textColor = UIColor.label
        let bgColor = UIColor.systemBackground
        // For RTL text, more padding on right (where text starts) and minimal on left (where text ends)
        let rightPadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24
        let leftPadding: CGFloat = 8  // Minimal padding on left side for RTL
        let topPadding: CGFloat = 8  // Reduced top padding
        let bottomPadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 28 : 20
        let htmlString = createHTMLString(textColor: textColor, bgColor: bgColor, fontSize: fontSize, rightPadding: rightPadding, leftPadding: leftPadding, topPadding: topPadding, bottomPadding: bottomPadding)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        return String(format: "#%06x", rgb)
    }
}
#elseif os(macOS)
struct HTMLWebView: NSViewRepresentable {
    let htmlContent: String
    var fontSize: CGFloat = 22
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.setValue(false, forKey: "drawsBackground")
        if let scrollView = webView.subviews.first?.subviews.first as? NSScrollView {
            scrollView.backgroundColor = .textBackgroundColor
            // Add padding for macOS as well - RTL: more padding on right, minimal on left, reduced top
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsets(top: 8, left: 8, bottom: 20, right: 24)
        }
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Update when content or fontSize changes
        updateWebView(webView)
    }
    
    private func updateWebView(_ webView: WKWebView) {
        let textColor = NSColor.labelColor
        let bgColor = NSColor.textBackgroundColor
        let htmlString = createHTMLString(textColor: textColor, bgColor: bgColor, fontSize: fontSize, rightPadding: 24, leftPadding: 8, topPadding: 8, bottomPadding: 20)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
}

extension NSColor {
    var hexString: String {
        guard let rgbColor = usingColorSpace(.deviceRGB) else {
            return "#000000"
        }
        let red = Int(rgbColor.redComponent * 255)
        let green = Int(rgbColor.greenComponent * 255)
        let blue = Int(rgbColor.blueComponent * 255)
        return String(format: "#%02x%02x%02x", red, green, blue)
    }
}
#endif

// Shared HTML creation function
extension HTMLWebView {
    func createHTMLString(textColor: Any, bgColor: Any, fontSize: CGFloat, rightPadding: CGFloat = 24, leftPadding: CGFloat = 8, topPadding: CGFloat = 8, bottomPadding: CGFloat = 20) -> String {
        let textColorHex: String
        let bgColorHex: String
        
        #if os(iOS)
        textColorHex = (textColor as! UIColor).hexString
        bgColorHex = (bgColor as! UIColor).hexString
        #elseif os(macOS)
        textColorHex = (textColor as! NSColor).hexString
        bgColorHex = (bgColor as! NSColor).hexString
        #endif
        
        return """
        <!DOCTYPE html>
        <html dir="rtl" lang="he">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
                    font-size: \(Int(fontSize))px;
                    line-height: 1.8;
                    color: \(textColorHex);
                    background-color: \(bgColorHex);
                    margin: 0;
                    padding-top: \(Int(topPadding))px;
                    padding-bottom: \(Int(bottomPadding))px;
                    padding-right: \(Int(rightPadding))px;
                    padding-left: \(Int(leftPadding))px;
                    direction: rtl;
                    text-align: right;
                    word-wrap: break-word;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    display: block;
                    margin: 12px auto;
                    border-radius: 4px;
                }
                big {
                    font-size: 1.3em;
                    font-weight: 600;
                }
                strong, b {
                    font-weight: bold;
                }
                i, em {
                    font-style: italic;
                }
                u {
                    text-decoration: underline;
                }
                p {
                    margin-bottom: 12px;
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
    }
}


#Preview {
    TextPanelView(
        title: "טקסט עברי",
        content: "זהו טקסט דוגמה בעברית. הטקסט יופיע כאן כאשר נתחבר ל-API של ספאריה."
    )
    .frame(width: 400, height: 600)
}

