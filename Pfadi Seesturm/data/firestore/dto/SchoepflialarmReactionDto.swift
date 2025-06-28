//
//  SchoepflialarmReactionDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import FirebaseFirestore

struct SchoepflialarmReactionDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    let userId: String
    let reaction: String
    
    func contentEquals(_ other: SchoepflialarmReactionDto) -> Bool {
        return id == other.id &&
            userId == other.userId &&
            reaction == other.reaction
    }
}

extension SchoepflialarmReactionDto {
    func toSchoepflialarmReaction(users: [FirebaseHitobitoUser]) throws -> SchoepflialarmReaction {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: modified)
        
        return SchoepflialarmReaction(
            id: id ?? UUID().uuidString,
            created: createdDate,
            modified: modifiedDate,
            createdFormatted: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "dd. MMM, HH:mm 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "dd. MMM, HH:mm 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            user: users.getUserById(uid: userId),
            reaction: try SchoepflialarmReactionType(string: reaction)
        )
    }
}
