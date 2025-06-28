//
//  SchoepflialarmDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import FirebaseFirestore

struct SchoepflialarmDto: FirestoreDto {
    
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    let message: String
    let userId: String
    
    func contentEquals(_ other: SchoepflialarmDto) -> Bool {
        return id == other.id &&
            message == other.message &&
            userId == other.userId
    }
}

extension SchoepflialarmDto {
    func toSchoepflialarm(users: [FirebaseHitobitoUser], reactions: [SchoepflialarmReactionDto]) throws -> Schoepflialarm {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: modified)
        
        return Schoepflialarm(
            id: id ?? UUID().uuidString,
            created: createdDate,
            modified: modifiedDate,
            createdFormatted: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "EEEE, dd. MMMM, HH:mm 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "EEEE, dd. MMMM, HH:mm 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            message: message,
            user: users.getUserById(uid: userId),
            reactions: try reactions.map { try $0.toSchoepflialarmReaction(users: users) }
        )
    }
}
