import Foundation

// Masechet (Tractate) model
struct Masechet: Codable, Identifiable, Hashable {
    let id: Int
    let order: Int
    let title: String
    let heTitle: String
    let pages: Int
    
    enum CodingKeys: String, CodingKey {
        case order, title, heTitle, pages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        order = try container.decode(Int.self, forKey: .order)
        title = try container.decode(String.self, forKey: .title)
        heTitle = try container.decode(String.self, forKey: .heTitle)
        pages = try container.decode(Int.self, forKey: .pages)
        id = order
    }
}

// Masechet data loader
class MasechetDataLoader: ObservableObject {
    @Published var masechtot: [Masechet] = []
    
    init() {
        loadMasechtot()
    }
    
    func loadMasechtot() {
        guard let url = Bundle.main.url(forResource: "masechet", withExtension: "json", subdirectory: "sources"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Masechet].self, from: data) else {
            print("Failed to load masechet.json")
            return
        }
        masechtot = decoded
    }
}

// Placeholder data models for future Sefaria API integration

struct DafYomiInfo {
    let date: Date
    let tractate: String
    let page: Int
    
    var hebrewDate: String {
        // Placeholder - will be implemented with proper Hebrew date calculation
        return "דף יומי היום"
    }
}

struct TalmudText {
    let text: String
    let source: String
}

struct Commentary {
    let text: String
    let type: CommentaryType
}

enum CommentaryType {
    case rashi
    case steinsaltz
}

// Hebrew Gematria converter
struct HebrewGematria {
    // Convert number to Hebrew Gematria notation
    static func toHebrew(_ number: Int) -> String {
        guard number > 0 else { return "" }
        
        var result = ""
        var remaining = number
        
        // Special cases for 15 and 16 (טו and טז) - must be checked first
        if remaining == 15 {
            return "טו"
        }
        if remaining == 16 {
            return "טז"
        }
        
        // Handle hundreds (100, 200, 300, 400)
        if remaining >= 400 {
            result += "ת"
            remaining -= 400
        } else if remaining >= 300 {
            result += "ש"
            remaining -= 300
        } else if remaining >= 200 {
            result += "ר"
            remaining -= 200
        } else if remaining >= 100 {
            result += "ק"
            remaining -= 100
        }
        
        // Handle tens (10-90)
        if remaining >= 90 {
            result += "צ"
            remaining -= 90
        } else if remaining >= 80 {
            result += "ף"
            remaining -= 80
        } else if remaining >= 70 {
            result += "ע"
            remaining -= 70
        } else if remaining >= 60 {
            result += "ס"
            remaining -= 60
        } else if remaining >= 50 {
            result += "נ"
            remaining -= 50
        } else if remaining >= 40 {
            result += "מ"
            remaining -= 40
        } else if remaining >= 30 {
            result += "ל"
            remaining -= 30
        } else if remaining >= 20 {
            result += "כ"
            remaining -= 20
        }
        
        // Handle ones (1-19, but skip 15 and 16 as they're special)
        if remaining >= 19 {
            result += "יט"
            remaining -= 19
        } else if remaining >= 18 {
            result += "יח"
            remaining -= 18
        } else if remaining >= 17 {
            result += "יז"
            remaining -= 17
        } else if remaining >= 16 {
            result += "טז"
            remaining -= 16
        } else if remaining >= 15 {
            result += "טו"
            remaining -= 15
        } else if remaining >= 14 {
            result += "יד"
            remaining -= 14
        } else if remaining >= 13 {
            result += "יג"
            remaining -= 13
        } else if remaining >= 12 {
            result += "יב"
            remaining -= 12
        } else if remaining >= 11 {
            result += "יא"
            remaining -= 11
        } else if remaining >= 10 {
            result += "י"
            remaining -= 10
        } else if remaining >= 9 {
            result += "ט"
            remaining -= 9
        } else if remaining >= 8 {
            result += "ח"
            remaining -= 8
        } else if remaining >= 7 {
            result += "ז"
            remaining -= 7
        } else if remaining >= 6 {
            result += "ו"
            remaining -= 6
        } else if remaining >= 5 {
            result += "ה"
            remaining -= 5
        } else if remaining >= 4 {
            result += "ד"
            remaining -= 4
        } else if remaining >= 3 {
            result += "ג"
            remaining -= 3
        } else if remaining >= 2 {
            result += "ב"
            remaining -= 2
        } else if remaining >= 1 {
            result += "א"
            remaining -= 1
        }
        
        return result.isEmpty ? "א" : result
    }
    
    // Generate list of Hebrew page numbers from start to end
    static func generatePageList(from start: Int, to end: Int) -> [(number: Int, hebrew: String)] {
        var pages: [(number: Int, hebrew: String)] = []
        for i in start...end {
            pages.append((number: i, hebrew: toHebrew(i)))
        }
        return pages
    }
}

// Daf content structure
struct DafContent: Codable {
    let gemara: String
    let rashi: [String]
    let steinsaltz: [String]
}

struct MasechetContent: Codable {
    let title: String
    let heTitle: String
    let dafs: [String: [DafContent]]
}

// Masechet content loader
class MasechetContentLoader: ObservableObject {
    @Published var content: MasechetContent?
    @Published var isLoading = false
    @Published var error: String?
    
    func loadMasechet(_ masechetTitle: String) {
        isLoading = true
        error = nil
        
        // Convert title to filename (e.g., "Bava Batra" -> "BavaBatra")
        let filename = masechetTitle.replacingOccurrences(of: " ", with: "")
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "sources"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(MasechetContent.self, from: data) else {
            error = "Failed to load \(filename).json"
            isLoading = false
            return
        }
        
        content = decoded
        isLoading = false
    }
    
    func getDafContent(page: Int, part: String) -> [DafContent]? {
        guard let content = content else { return nil }
        let dafKey = "\(page)\(part)" // e.g., "2a" or "2b"
        return content.dafs[dafKey]
    }
}

