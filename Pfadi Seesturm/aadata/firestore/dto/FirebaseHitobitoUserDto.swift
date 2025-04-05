//
//  FirestoreHitobitoUserDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.03.2025.
//
import FirebaseFirestore

struct FirebaseHitobitoUserDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    var email: String?
    var firstName: String?
    var lastName: String?
    var pfadiName: String?
    
    func contentEquals(_ other: FirebaseHitobitoUserDto) -> Bool {
        return id == other.id &&
        email == other.email &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        pfadiName == other.pfadiName
    }
}

extension FirebaseHitobitoUserDto {
    func toFirebaseHitobitoUser() throws -> FirebaseHitobitoUser {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestampToDate(timestamp: created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestampToDate(timestamp: modified)
        
        return FirebaseHitobitoUser(
            userId: id ?? UUID().uuidString,
            vorname: firstName,
            nachname: lastName,
            pfadiname: pfadiName,
            email: email,
            created: createdDate,
            createdFormatted: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "EEEE, d. MMMM yyyy",
                withRelativeDateFormatting: true,
                includeTimeInRelativeFormatting: true,
                timeZone: .current
            ),
            modified: modifiedDate,
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "EEEE, d. MMMM yyyy",
                withRelativeDateFormatting: true,
                includeTimeInRelativeFormatting: true,
                timeZone: .current
            )
        )
    }
}
