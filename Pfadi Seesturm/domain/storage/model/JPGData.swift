//
//  JPGData.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.08.2025.
//
import SwiftUI
import PhotosUI

struct JPGData {
    
    let wrappedData: Data
    
    init(from data: Data, compressionQuality: CGFloat = 0.5) throws {
        
        guard let image = UIImage(data: data), let jpgData = image.jpegData(compressionQuality: compressionQuality) else {
            throw PfadiSeesturmError.jpgConversionFailed(message: "Bild konnte nicht in JPG konvertiert werden.")
        }
        
        self.wrappedData = jpgData
    }
    
    init(from photosPickerItem: PhotosPickerItem) async throws {
        
        guard let imageData = try await photosPickerItem.loadTransferable(type: Data.self) else {
            throw PfadiSeesturmError.jpgConversionFailed(message: "Bild konnte nicht in JPG konvertiert werden.")
        }
        
        try self.init(from: imageData)
    }
}
