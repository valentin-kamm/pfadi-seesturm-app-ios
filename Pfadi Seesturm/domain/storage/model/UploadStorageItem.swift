//
//  UploadStorageItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import UIKit

enum UploadStorageItem {
    
    case profilePicture(user: FirebaseHitobitoUser, data: ProfilePicture)
    
    var path: String {
        switch self {
        case .profilePicture(let user, _):
            return user.profilePictureStoragePath
        }
    }
    
    var data: Data {
        switch self {
        case .profilePicture(_, let data):
            return data.compressedJPGData
        }
    }
    
    var contentType: String {
        switch self {
        case .profilePicture(_, _):
            return "image/jpeg"
        }
    }
}
