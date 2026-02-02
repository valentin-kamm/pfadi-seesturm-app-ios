//
//  ManageEventPreviewType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2026.
//

enum EventPreviewType {
    
    case aktivitaet(stufe: SeesturmStufe)
    case multipleAktivitaeten(stufen: Set<SeesturmStufe>)
    case termin(calendar: SeesturmCalendar)
    
    var navigationTitle: String {
        switch self {
        case .aktivitaet(let stufe):
            "Vorschau \(stufe.aktivitaetDescription)"
        case .multipleAktivitaeten(_):
            "Vorschau Aktivitäten"
        case .termin(_):
            "Vorschau Anlass"
        }
    }
}
