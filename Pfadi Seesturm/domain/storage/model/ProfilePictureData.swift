//
//  ProfilePictureData.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import SwiftUI
import PhotosUI

struct ProfilePictureData: Identifiable {
    
    let compressedJPGData: Data
    let originalUiImage: UIImage
    
    var id: Int {
        self.originalUiImage.hashValue
    }
    
    private let defaultCompressionQuality: CGFloat = 0.5
    
    init(from photosPickerItem: PhotosPickerItem) async throws {
        
        let error = PfadiSeesturmError.jpgConversion(message: "Bild konnte nicht in JPG konvertiert werden.")
        let quality = self.defaultCompressionQuality
        
        guard let originalData = try await photosPickerItem.loadTransferable(type: Data.self) else {
            throw error
        }
        
        let result = try await Task.detached(priority: .userInitiated) {
            guard
                let originalImage = UIImage(data: originalData),
                let compressedData = originalImage.jpegData(compressionQuality: quality)
            else {
                throw error
            }
            return (originalImage, compressedData)
        }.value
        
        self.originalUiImage = result.0
        self.compressedJPGData = result.1
    }
    
    init(from uiImage: UIImage) async throws {
        
        let error = PfadiSeesturmError.jpgConversion(message: "Bild konnte nicht in JPG konvertiert werden.")
        let quality = self.defaultCompressionQuality
        
        let result = try await Task.detached(priority: .userInitiated) {
            guard
                let originalData = uiImage.jpegData(compressionQuality: 1),
                let originalImage = UIImage(data: originalData),
                let compressedData = originalImage.jpegData(compressionQuality: quality)
            else {
                throw error
            }
            return (originalImage, compressedData)
        }.value
        
        self.originalUiImage = result.0
        self.compressedJPGData = result.1
    }
}
