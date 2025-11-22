import SwiftUI
import PhotosUI
import SwiftData

struct ScannerView: View {
    @Query private var allItems: [ClothingItem]
    @State private var viewModel = WardrobeViewModel()
    
    @State private var isShowingPicker = false
    @State private var selectedItem: PhotosPickerItem?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Scanner Area
                    VStack {
                        if let scannedImage = viewModel.scannedImage {
                            Image(uiImage: scannedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(radius: 5)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 250)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                            .foregroundStyle(.secondary)
                                    )
                                
                                VStack {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.secondary)
                                    Text("Tap to Scan Sneaker")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .onTapGesture {
                        isShowingPicker = true
                    }
                    
                    if viewModel.isScanning {
                        ProgressView("Analyzing colors...")
                    }
                    
                    // Results Area
                    if !viewModel.matchedItems.isEmpty {
                        VStack(alignment: .leading) {
                            Text("In Your Closet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(viewModel.matchedItems) { item in
                                    VStack {
                                        if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                        
                                        HStack {
                                            Circle()
                                                .fill(item.color)
                                                .frame(width: 12, height: 12)
                                            Text(item.category.rawValue)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Text("Match!")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else if viewModel.scannedImage != nil && !viewModel.isScanning {
                        ContentUnavailableView("No Matches Found", systemImage: "tshirt.slash", description: Text("Try scanning a different sneaker or add more items to your closet."))
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Compatibility Checker")
            .toolbar {
                if viewModel.scannedImage != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Clear") {
                            viewModel.clearScan()
                            selectedItem = nil
                        }
                    }
                }
            }
            .photosPicker(isPresented: $isShowingPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        // Perform compatibility check
                        viewModel.checkCompatibility(for: image, allItems: allItems)
                    }
                }
            }
        }
    }
}
