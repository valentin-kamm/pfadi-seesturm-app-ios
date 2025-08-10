//
//  StorageItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.08.2025.
//
import SwiftUI
import PhotosUI
import FirebaseStorage

enum StorageItem {
    case profilePicture(user: FirebaseHitobitoUser, item: PhotosPickerItem)
    
    func getReference(storage: Storage) -> StorageReference {
        switch self {
        case .profilePicture(let user, _):
            return storage.reference().child("profilePictures/\(user.userId).jpg")
        }
    }
    
    func getData() async throws  -> Data {
        switch self {
        case .profilePicture(_, let item):
            return try await JPGData(from: item).wrappedData
        }
    }
}
