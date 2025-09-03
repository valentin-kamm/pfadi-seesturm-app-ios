//
//  JPGData.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.08.2025.
//
import SwiftUI
import PhotosUI

struct JPGData: Identifiable {
    
    let compressedData: Data
    let originalUiImage: UIImage
    
    var id: Int {
        self.originalUiImage.hashValue
    }
    
    private let defaultCompressionQuality: CGFloat = 0.5
    
    init(from photosPickerItem: PhotosPickerItem) async throws {
        
        guard
            let originalData = try await photosPickerItem.loadTransferable(type: Data.self),
            let originalImage = UIImage(data: originalData),
            let compressedData = originalImage.jpegData(compressionQuality: defaultCompressionQuality)
        else {
            throw PfadiSeesturmError.jpgConversionFailed(message: "Bild konnte nicht in JPG konvertiert werden.")
        }
        
        self.compressedData = compressedData
        self.originalUiImage = originalImage
    }
    
    init(from uiImage: UIImage) throws {
        guard
            let originalData = uiImage.jpegData(compressionQuality: 1),
            let originalImage = UIImage(data: originalData),
            let compressedData = originalImage.jpegData(compressionQuality: defaultCompressionQuality)
        else {
            throw PfadiSeesturmError.jpgConversionFailed(message: "Bild konnte nicht in JPG konvertiert werden.")
        }
        
        self.compressedData = compressedData
        self.originalUiImage = originalImage
    }
}
