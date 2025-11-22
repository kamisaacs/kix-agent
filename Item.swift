import SwiftUI
import SwiftData
import Foundation

enum ClothingCategory: String, Codable, CaseIterable, Identifiable {
    case sneaker = "Sneaker"
    case top = "Top"
    case bottom = "Bottom"
    case accessory = "Accessory"
    
    var id: String { self.rawValue }
}

@Model
final class ClothingItem {
    var id: UUID
    @Attribute(.externalStorage) var imageData: Data? // Use external storage for large images
    var hexColor: String
    var category: ClothingCategory
    var timestamp: Date
    
    init(id: UUID = UUID(), imageData: Data? = nil, hexColor: String, category: ClothingCategory, timestamp: Date = Date()) {
        self.id = id
        self.imageData = imageData
        self.hexColor = hexColor
        self.category = category
        self.timestamp = timestamp
    }
    
    // Helper to convert stored hex string to SwiftUI Color
    var color: Color {
        Color(hex: hexColor) ?? .gray
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    // Helper to get hex string from Color (for saving)
    func toHex() -> String? {
        // This is a simplified implementation. 
        // In a real app, you'd extract components from UIColor/NSColor
        // For this example, we assume the color was created from hex or is a standard color we can convert.
        // A robust implementation would use UIColor(self).cgColor.components
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if a != 1.0 {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
