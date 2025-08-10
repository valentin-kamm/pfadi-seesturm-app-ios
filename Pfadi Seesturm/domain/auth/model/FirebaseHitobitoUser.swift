//
//  FirebaseHitobitoUser.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//
import Foundation

struct FirebaseHitobitoUser: Codable, Hashable, Identifiable {
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
    
    init(_ dto: FirebaseHitobitoUserDto) throws {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: dto.created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: dto.modified)
        
        guard let uid = dto.id else {
            throw PfadiSeesturmError.authError(message: "Die User ID ist ungültig.")
        }
        
        self.userId = uid
        self.vorname = dto.firstname
        self.nachname = dto.lastname
        self.pfadiname = dto.pfadiname
        self.email = dto.email
        self.role = try FirebaseHitobitoUserRole(role: dto.role)
        self.profilePictureUrl = dto.profilePictureUrl.flatMap(URL.init)
        self.created = createdDate
        self.createdFormatted = DateTimeUtil.shared.formatDate(
            date: createdDate,
            format: "EEEE, d. MMMM yyyy 'Uhr'",
            timeZone: .current,
            type: .relative(withTime: true)
        )
        self.modified = modifiedDate
        self.modifiedFormatted = DateTimeUtil.shared.formatDate(
            date: modifiedDate,
            format: "EEEE, d. MMMM yyyy 'Uhr'",
            timeZone: .current,
            type: .relative(withTime: true)
        )
        self.fcmToken = dto.fcmToken
    }
    
    var id: String {
        userId
    }
    
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
