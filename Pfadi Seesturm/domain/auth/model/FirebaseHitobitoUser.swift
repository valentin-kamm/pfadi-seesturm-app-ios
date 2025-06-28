//
//  FirebaseHitobitoUser.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//
import Foundation

struct FirebaseHitobitoUser: Codable, Hashable {
    let userId: String
    let vorname: String?
    let nachname: String?
    let pfadiname: String?
    let email: String?
    let role: FirebaseHitobitoUserRole
    let profilePictureUrl: URL?
    let created: Date
    let createdFormatted: String
    let modified: Date
    let modifiedFormatted: String
    var fcmToken: String?
    
    var displayNameShort: String {
        pfadiname ?? vorname ?? "Unbekannter Benutzer"
    }
}

extension [FirebaseHitobitoUser] {
    func getUserById(uid: String) -> FirebaseHitobitoUser? {
        return first { $0.userId == uid }
    }
    func getUsersById(uids: [String]) -> [FirebaseHitobitoUser?] {
        return uids.map { getUserById(uid: $0) }
    }
}
