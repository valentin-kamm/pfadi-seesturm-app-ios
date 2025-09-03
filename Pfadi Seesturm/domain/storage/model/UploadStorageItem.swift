//
//  UploadStorageItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.08.2025.
//
import SwiftUI
import PhotosUI
import FirebaseStorage

enum UploadStorageItem {
    case profilePicture(user: FirebaseHitobitoUser, data: JPGData)
    
    func getReference(storage: Storage) -> StorageReference {
        switch self {
        case .profilePicture(let user, _):
            return storage.reference().child("profilePictures/\(user.userId).jpg")
        }
    }
    
    func getData() throws  -> Data {
        switch self {
        case .profilePicture(_, let item):
            return item.compressedData
        }
    }
    
    var metadata: StorageMetadata {
        let metadata = StorageMetadata()
        switch self {
        case .profilePicture(_, _):
            metadata.contentType = "image/jpeg"
        }
        return metadata
    }
}
