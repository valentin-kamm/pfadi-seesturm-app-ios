//
//  AktivitaetTemplateDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.04.2025.
//
import FirebaseFirestore

struct AktivitaetTemplateDto: FirestoreDto {
    
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    let stufenId: Int
    let description: String
    
    func contentEquals(_ other: AktivitaetTemplateDto) -> Bool {
        return id == other.id &&
        stufenId == other.stufenId &&
        description == other.description
    }
}

extension AktivitaetTemplateDto {
    func toAktivitaetTemplate() throws -> AktivitaetTemplate {
        return AktivitaetTemplate(
            id: id ?? UUID().uuidString,
            created: try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: created),
            modified: try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: modified),
            stufe: try SeesturmStufe(id: stufenId),
            description: description
        )
    }
}
