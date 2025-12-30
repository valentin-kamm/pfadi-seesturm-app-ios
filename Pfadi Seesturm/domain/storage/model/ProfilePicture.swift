//
//  ProfilePicture.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2025.
//
import SwiftUI

struct ProfilePicture {
    
    let compressedJPGData: Data
    
    init(from uiImage: UIImage) async throws {
        
        let result = try await Task.detached(priority: .userInitiated) {
            guard
                let originalJPGData = uiImage.jpegData(compressionQuality: 1),
                let originalJPGImage = UIImage(data: originalJPGData),
                let compressedJPGData = originalJPGImage
                    .shrink(to: Constants.PROFILE_PICTURE_SIZE)
                    .jpegData(compressionQuality: Constants.PROFILE_PICTURE_COMPRESSION_QUALITY)
            else {
                throw PfadiSeesturmError.jpgConversion(message: "Das Profilbild ist nicht quadratisch.")
            }
            return compressedJPGData
        }.value
        
        self.compressedJPGData = result
    }
}
