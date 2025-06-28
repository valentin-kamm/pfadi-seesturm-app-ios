//
//  FirestoreHitobitoUserDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.03.2025.
//
import FirebaseFirestore
import Foundation

struct FirebaseHitobitoUserDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    var email: String?
    var firstname: String?
    var lastname: String?
    var pfadiname: String?
    var role: String
    var profilePictureUrl: String?
    var fcmToken: String?
    
    func contentEquals(_ other: FirebaseHitobitoUserDto) -> Bool {
        return id == other.id &&
        email == other.email &&
        firstname == other.firstname &&
        lastname == other.lastname &&
        pfadiname == other.pfadiname &&
        role == other.role &&
        profilePictureUrl == other.profilePictureUrl &&
        fcmToken == other.fcmToken
    }
}

extension FirebaseHitobitoUserDto {
    func toFirebaseHitobitoUser() throws -> FirebaseHitobitoUser {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: modified)
        
        return FirebaseHitobitoUser(
            userId: id ?? UUID().uuidString,
            vorname: firstname,
            nachname: lastname,
            pfadiname: pfadiname,
            email: email,
            role: try FirebaseHitobitoUserRole(role: role),
            profilePictureUrl: URL(string: profilePictureUrl ?? ""),
            created: createdDate,
            createdFormatted: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "EEEE, d. MMMM yyyy 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            modified: modifiedDate,
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "EEEE, d. MMMM yyyy 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            fcmToken: fcmToken
        )
    }
}
