//
//  DeleteStorageItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

enum DeleteStorageItem {
    
    case profilePicture(user: FirebaseHitobitoUser)
    
    var path: String {
        switch self {
        case .profilePicture(let user):
            return user.profilePictureStoragePath
        }
    }
}
