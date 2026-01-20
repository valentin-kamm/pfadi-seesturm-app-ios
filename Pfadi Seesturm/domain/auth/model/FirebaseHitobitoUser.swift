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
    
    var id: String {
        userId
    }
    
    var displayNameShort: String {
        pfadiname ?? vorname ?? "Unbekannter Benutzer"
    }
    
    var displayNameFull: String {
        if let pn = pfadiname, let vn = vorname, let nn = nachname {
            return "\(vn) \(nn) / \(pn)"
        }
        else if let vn = vorname, let nn = nachname {
            return "\(vn) \(nn)"
        }
        else if let vn = vorname {
            return vn
        }
        else {
            return "Unbekannter Benutzer"
        }
    }
    
    var profilePictureStoragePath: String {
        return "profilePictures/\(userId).jpg"
    }
    
    init(_ dto: FirebaseHitobitoUserDto) throws {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: dto.created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: dto.modified)
        
        self.userId = dto.id ?? UUID().uuidString
        self.vorname = dto.firstname
        self.nachname = dto.lastname
        self.pfadiname = dto.pfadiname
        self.email = dto.email
        self.role = try FirebaseHitobitoUserRole(role: dto.role)
        self.profilePictureUrl = URL(string: dto.profilePictureUrl ?? "")
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
    
    init(_ oldUser: FirebaseHitobitoUser, newProfilePictureUrl: URL?) {
        
        let now = Date()
        
        self.userId = oldUser.userId
        self.vorname = oldUser.vorname
        self.nachname = oldUser.nachname
        self.pfadiname = oldUser.pfadiname
        self.email = oldUser.email
        self.role = oldUser.role
        self.profilePictureUrl = newProfilePictureUrl
        self.created = oldUser.created
        self.createdFormatted = oldUser.createdFormatted
        self.modified = now
        self.modifiedFormatted = DateTimeUtil.shared.formatDate(
            date: now,
            format: "EEEE, d. MMMM yyyy 'Uhr'",
            timeZone: .current,
            type: .relative(withTime: true)
        )
        self.fcmToken = oldUser.fcmToken
    }
    
    var isAdmin: Bool {
        switch self.role {
        case .user:
            return false
        case .admin:
            return true
        }
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
