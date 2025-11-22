import SwiftUI
import UIKit

class ColorService {
    
    // MARK: - Color Extraction
    
    /// Extracts the dominant color from an image.
    /// - Parameter image: The source UIImage.
    /// - Returns: The dominant Color.
    static func extractDominantColor(from image: UIImage) -> Color {
        // TODO: Implement real dominant color extraction (e.g., using k-means clustering or CoreImage).
        // For now, we return a mock color or a simple average to keep it runnable.
        // A simple way to get *a* color is to resize to 1x1 and pick that pixel.
        
        guard let inputImage = CIImage(image: image) else { return .gray }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return .gray }
        guard let outputImage = filter.outputImage else { return .gray }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return Color(red: Double(bitmap[0]) / 255.0, green: Double(bitmap[1]) / 255.0, blue: Double(bitmap[2]) / 255.0, opacity: Double(bitmap[3]) / 255.0)
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
