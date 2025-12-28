//
//  PickedGalleryImage.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2025.
//
import SwiftUI
import PhotosUI

struct PickedGalleryImage: Identifiable {
    
    let uiImage: UIImage
    
    var id: Int {
        self.uiImage.hashValue
    }
    
    init(photosPickerItem: PhotosPickerItem) async throws {
        
        guard
            let data = try await photosPickerItem.loadTransferable(type: Data.self),
            let image = UIImage(data: data)
        else {
            throw PfadiSeesturmError.jpgConversion(message: "Bild konnte nicht aus der Gallerie geladen werden.")
        }
        
        self.uiImage = image
    }
}
