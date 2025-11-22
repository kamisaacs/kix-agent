import SwiftUI
import SwiftData
import PhotosUI

@Observable
class WardrobeViewModel {
    var modelContext: ModelContext?
    var scannedImage: UIImage?
    var matchedItems: [ClothingItem] = []
    var isScanning: Bool = false
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
    
    // MARK: - Data Operations
    
    func addItem(image: UIImage, category: ClothingCategory, hexColor: String) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let newItem = ClothingItem(imageData: imageData, hexColor: hexColor, category: category)
        modelContext?.insert(newItem)
        // SwiftData autosaves, but explicit save can be good for debugging
        try? modelContext?.save()
    }
    
    func deleteItems(offsets: IndexSet, items: [ClothingItem]) {
        for index in offsets {
            let item = items[index]
            modelContext?.delete(item)
        }
    }
    
    // MARK: - Compatibility Logic
    
    /// Checks compatibility for a captured image against the wardrobe.
    /// - Parameter capturedImage: The image from the scanner.
    /// - Parameter allItems: Pass in the current list of items (fetched in View).
    func checkCompatibility(for capturedImage: UIImage, allItems: [ClothingItem]) {
        self.isScanning = true
        self.scannedImage = capturedImage
        
        // 1. Extract color
        let dominantColor = ColorService.extractDominantColor(from: capturedImage)
        print("Extracted Color: \(dominantColor.description)")
        
        // 2. Generate matches
        let targetColors = ColorService.findMatches(for: dominantColor)
        
        // 3. Filter existing items
        // We want to find items in the wardrobe that match the generated target colors.
        // e.g. If sneaker is Red, we want Green (Comp) or Orange/Purple (Analogous) items.
        
        self.matchedItems = allItems.filter { item in
            // Check if the item's color is similar to ANY of the target matching colors
            targetColors.contains { targetColor in
                ColorService.areColorsSimilar(item.color, targetColor, tolerance: 0.3) // Tweak tolerance here
            }
        }
        
        self.isScanning = false
    }
    
    func clearScan() {
        self.scannedImage = nil
        self.matchedItems = []
    }
}
