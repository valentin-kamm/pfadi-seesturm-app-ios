//
//  FirestoreDataStructures.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import Foundation
import FirebaseFirestore

protocol StructWithIdField {
    var firestoreDocumentId: String? { get set }
}

struct AktivitaetAnAbmeldungOld: Codable, StructWithIdField {
    var firestoreDocumentId: String?
    var eventId: String
    var vorname: String
    var nachname: String
    var pfadiname: String?
    var bemerkung: String?
    var type: Int
    var stufenId: Int
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
}
struct TransformedAktivitaetAnAbmeldung: Decodable {
    var firestoreDocumentId: String
    var eventId: String
    var vorname: String
    var nachname: String
    var pfadiname: String?
    var bemerkung: String?
    var type: AktivitaetAktion
    var stufe: SeesturmStufeOld
    var created: Date
    var modified: Date
    var createdString: String
    var modifiedString: String
    
    var displayName: String {
        if let pfadiname = pfadiname {
            return "\(vorname) \(nachname) / \(pfadiname)"
        }
        else {
            return "\(vorname) \(nachname)"
        }
    }
    
    
}
extension AktivitaetAnAbmeldungOld {
    func toTransformedAktivitaetAnAbmeldung() throws -> TransformedAktivitaetAnAbmeldung {
        return TransformedAktivitaetAnAbmeldung(
            firestoreDocumentId: firestoreDocumentId ?? UUID().uuidString,
            eventId: eventId,
            vorname: vorname,
            nachname: nachname,
            pfadiname: pfadiname,
            bemerkung: bemerkung,
            type: try AktivitaetAktion(id: type),
            stufe: try SeesturmStufeOld(id: stufenId),
            created: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: created),
            modified: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: modified),
            createdString: DateTimeUtil.shared.formatDate(date: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: created), format: "EEEE, dd. MMMM, HH:mm", withRelativeDateFormatting: true, includeTimeInRelativeFormatting: true, timeZone: .current),
            modifiedString: DateTimeUtil.shared.formatDate(date: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: modified), format: "EEEE, dd. MMMM, HH:mm", withRelativeDateFormatting: true, includeTimeInRelativeFormatting: true, timeZone: .current)
        )
    }
}
struct TransformedCalendarEventResponseWithAnAbmeldungen: Identifiable {
    var id: String
    var title: String
    var startDate: Date
    var anAbmeldungen: [TransformedAktivitaetAnAbmeldung]
    
    var displayTextAbmeldungen: String {
        let count = anAbmeldungen.count { $0.type == .abmelden }
        return "\(count) " + (count == 1 ? "Abmeldung" : "Abmeldungen")
    }
    var displayTextAnmeldungen: String {
        let count = anAbmeldungen.count { $0.type == .anmelden }
        return "\(count) " + (count == 1 ? "Anmeldung" : "Anmeldungen")
    }
    var startDateIsInFuture: Bool {
        return startDate > Date()
    }
    
}
extension GoogleCalendarEvent {
    func toAktivitaetWithAnAbmeldungen(anAbmeldungen: [TransformedAktivitaetAnAbmeldung]) -> TransformedCalendarEventResponseWithAnAbmeldungen {
        return TransformedCalendarEventResponseWithAnAbmeldungen(
            id: id,
            title: "\(title) (\(fullDateTimeString))",
            startDate: startDate,
            anAbmeldungen: getAnAbmeldungenForEventId(eventId: id, anAbmeldungen: anAbmeldungen)
        )
    }
    private func getAnAbmeldungenForEventId(eventId: String, anAbmeldungen: [TransformedAktivitaetAnAbmeldung]) -> [TransformedAktivitaetAnAbmeldung] {
        return anAbmeldungen.filter { $0.eventId == id }
    }
}

struct Schöpflialarm: Codable {
    var message: String
    var userId: Int
    var responses: [SchöpflialarmReaction]
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
}
struct SchöpflialarmReaction: Codable {
    var userId: Int
    var responseType: Int
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
}
struct TransformedSchöpflialarm {
    var message: String
    var user: FirebaseHitobitoUser?
    var responses: [TransformedSchöpflialarmReaction]
    var created: Date
    var modified: Date
}
struct TransformedSchöpflialarmReaction {
    var user: FirebaseHitobitoUser?
    var responseType: SchöpflialarmResponseType
    var created: Date
    var modified: Date
}

/*
extension Schöpflialarm {
    func toTransformedSchöpflialarm(users: [FirebaseHitobitoUser]) throws -> TransformedSchöpflialarm {
        return TransformedSchöpflialarm(
            message: message,
            user: FirebaseAuthService.shared.getUser(for: userId, fromUsers: users),
            responses: try responses.map { try $0.toTransformedSchöpflialarmReaction(users: users) },
            created: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: created),
            modified: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: modified)
        )
    }
    func getCreatedDate() throws -> Date {
        return try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: created)
    }
}
extension SchöpflialarmReaction {
    func toTransformedSchöpflialarmReaction(users: [FirebaseHitobitoUser]) throws -> TransformedSchöpflialarmReaction {
        return TransformedSchöpflialarmReaction(
            user: FirebaseAuthService.shared.getUser(for: userId, fromUsers: users),
            responseType: try SchöpflialarmResponseType(id: responseType),
            created: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: created),
            modified: try FirestoreManager.shared.convertFirestoreTimestampToDate(timestamp: modified)
        )
    }
}
*/
