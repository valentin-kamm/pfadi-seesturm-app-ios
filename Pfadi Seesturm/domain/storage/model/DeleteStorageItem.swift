//
//  DeleteStorageItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 13.08.2025.
//

import FirebaseStorage

enum DeleteStorageItem {
    
    case profilePicture(user: FirebaseHitobitoUser)
    
    func getReference(storage: Storage) -> StorageReference {
        switch self {
        case .profilePicture(let user):
            return storage.reference().child("profilePictures/\(user.userId).jpg")
        }
    }
}
