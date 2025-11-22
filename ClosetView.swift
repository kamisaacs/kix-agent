import SwiftUI
import SwiftData
import PhotosUI

struct ClosetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ClothingItem.timestamp, order: .reverse) private var items: [ClothingItem]
    @State private var viewModel = WardrobeViewModel()
    
    @State private var isShowingPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isShowingAddSheet = false
    
    // Add Sheet State
    @State private var newCategory: ClothingCategory = .sneaker
    @State private var newHexColor: String = "#FFFFFF"
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(items) { item in
                        VStack {
                            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 150, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            
                            HStack {
                                Circle()
                                    .fill(item.color)
                                    .frame(width: 12, height: 12)
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                Text(item.category.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .photosPicker(isPresented: $isShowingPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        // Auto-extract color for the add sheet
                        let color = ColorService.extractDominantColor(from: image)
                        newHexColor = Color(color).toHex() ?? "#FFFFFF"
                        isShowingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                NavigationStack {
                    Form {
                        if let selectedImage {
                            HStack {
                                Spacer()
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Spacer()
                            }
                        }
                        
                        Picker("Category", selection: $newCategory) {
                            ForEach(ClothingCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        
                        HStack {
                            Text("Dominant Color")
                            Spacer()
                            Color(hex: newHexColor)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        }
                        
                        // Optional: Allow manual override of color if needed (not implemented for simplicity)
                    }
                    .navigationTitle("Add New Item")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isShowingAddSheet = false
                                selectedItem = nil
                                selectedImage = nil
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if let selectedImage {
                                    // We need to use the ViewModel attached to the context or just use context directly.
                                    // Here we use the local ViewModel helper but we need to inject the context.
                                    viewModel.modelContext = modelContext
                                    viewModel.addItem(image: selectedImage, category: newCategory, hexColor: newHexColor)
                                }
                                isShowingAddSheet = false
                                selectedItem = nil
                                selectedImage = nil
                            }
                        }
                    }
                }
            }
        }
    }
}
