//
//  AktivitaetDetailViewType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 13.06.2025.
//

enum AktivitaetDetailViewType {
    case home(input: DetailInputType<String, GoogleCalendarEvent?>)
    case stufenbereich(event: GoogleCalendarEvent)
    
    var anAbmeldenButtonsDisabled: Bool {
        switch self {
        case .home(_):
            return false
        case .stufenbereich(_):
            return true
        }
    }
}
