//
//  AktivitaetAnAbmeldungDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import FirebaseFirestore

struct AktivitaetAnAbmeldungDto: FirestoreDto {
    @DocumentID var id: String?
    var eventId: String
    var uid: String?
    var vorname: String
    var nachname: String
    var pfadiname: String?
    var bemerkung: String?
    var typeId: Int
    var stufenId: Int
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    
    func contentEquals(_ other: AktivitaetAnAbmeldungDto) -> Bool {
        return id == other.id &&
        eventId == other.eventId &&
        uid == other.uid &&
        vorname == other.vorname &&
        nachname == other.nachname &&
        pfadiname == other.pfadiname &&
        bemerkung == other.bemerkung &&
        typeId == other.typeId &&
        stufenId == other.stufenId
    }
}

extension AktivitaetAnAbmeldungDto {
    func toAktivitaetAnAbmeldung() throws -> AktivitaetAnAbmeldung {
        
        let createdDate = try DateTimeUtil.shared.convertFirestoreTimestampToDate(timestamp: created)
        let modifiedDate = try DateTimeUtil.shared.convertFirestoreTimestampToDate(timestamp: modified)
        
        return AktivitaetAnAbmeldung(
            id: id ?? UUID().uuidString,
            eventId: eventId,
            uid: uid,
            vorname: vorname,
            nachname: nachname,
            pfadiname: pfadiname,
            bemerkung: bemerkung,
            type: try AktivitaetInteraction(id: typeId),
            stufe: try SeesturmStufe(id: stufenId),
            created: createdDate,
            modified: modifiedDate,
            createdString: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "EEEE, dd. MMMM, HH:mm",
                withRelativeDateFormatting: true,
                includeTimeInRelativeFormatting: true,
                timeZone: .current
            ),
            modifiedString: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "EEEE, dd. MMMM, HH:mm",
                withRelativeDateFormatting: true,
                includeTimeInRelativeFormatting: true,
                timeZone: .current
            )
        )
    }
}
