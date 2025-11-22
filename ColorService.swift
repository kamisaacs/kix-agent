import SwiftUI
import UIKit

class ColorService {
    
    // MARK: - Color Extraction
    
    /// Extracts the dominant color from an image.
    /// - Parameter image: The source UIImage.
    /// - Returns: The dominant Color.
    static func extractDominantColor(from image: UIImage) -> Color {
        // Resize image to 1x1 to get average color
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        
        guard let cgImage = resizedImage.cgImage,
              let dataProvider = cgImage.dataProvider,
              let data = dataProvider.data,
              let ptr = CFDataGetBytePtr(data) else {
            return .gray
        }
        
        // CGImage data is usually RGBA or similar, but UIGraphicsImageRenderer usually produces sRGB
        // We assume standard 8-bit per component.
        // Note: This is a simplified extraction.
        
        let r = CGFloat(ptr[0]) / 255.0
        let g = CGFloat(ptr[1]) / 255.0
        let b = CGFloat(ptr[2]) / 255.0
        let a = CGFloat(ptr[3]) / 255.0
        
        return Color(red: Double(r), green: Double(g), blue: Double(b), opacity: Double(a))
    }
    
    // MARK: - Color Matching Logic
    
    /// Finds matching colors based on HSB Color Theory.
    /// - Parameter targetColor: The color to match against.
    /// - Returns: An array of matching Colors (Complementary, Analogous).
    static func findMatches(for targetColor: Color) -> [Color] {
        var matches: [Color] = []
        
        // Convert SwiftUI Color to UIColor to get HSB
        let uiColor = UIColor(targetColor)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        guard uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return []
        }
        
        // 1. Complementary Color (Opposite Hue: +0.5 or 180 degrees)
        let compHue = (hue + 0.5).truncatingRemainder(dividingBy: 1.0)
        let complementary = Color(hue: compHue, saturation: Double(saturation), brightness: Double(brightness))
        matches.append(complementary)
        
        // 2. Analogous Colors (Neighboring Hues: +/- 30 degrees -> +/- 0.0833)
        let analogousOffset: CGFloat = 30.0 / 360.0
        
        let analog1Hue = (hue + analogousOffset).truncatingRemainder(dividingBy: 1.0)
        let analog1 = Color(hue: analog1Hue, saturation: Double(saturation), brightness: Double(brightness))
        matches.append(analog1)
        
        let analog2Hue = (hue - analogousOffset + 1.0).truncatingRemainder(dividingBy: 1.0) // Ensure positive
        let analog2 = Color(hue: analog2Hue, saturation: Double(saturation), brightness: Double(brightness))
        matches.append(analog2)
        
        return matches
    }
    
    // MARK: - Matching Tolerance Helper
    
    /// Checks if two colors are similar within a certain tolerance.
    /// - Parameters:
    ///   - color1: First color.
    ///   - color2: Second color.
    ///   - tolerance: Distance tolerance (0.0 to 1.0). Lower is stricter.
    /// - Returns: True if similar.
    static func areColorsSimilar(_ color1: Color, _ color2: Color, tolerance: CGFloat = 0.2) -> Bool {
        // Convert to CIColor or UIColor components to compare distance in RGB or Lab space.
        // Using simple RGB distance for MVP.
        
        let c1 = UIColor(color1)
        let c2 = UIColor(color2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        c1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let distance = sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2))
        
        // TWEAK HERE: Adjust "tolerance" parameter in calls or default value to change strictness.
        return distance < tolerance
    }
}
