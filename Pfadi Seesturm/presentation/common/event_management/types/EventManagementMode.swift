//
//  EventManagementMode.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.06.2025.
//

enum EventManagementMode: Hashable {
    
    case insert
    case update(eventId: String)
    
    var verb: String {
        switch self {
        case .insert:
            "veröffentlichen"
        case .update(_):
            "aktualisieren"
        }
    }
    var verbPassiv: String {
        switch self {
        case .insert:
            "veröffentlicht"
        case .update(_):
            "aktualisiert"
        }
    }
    var nomen: String {
        switch self {
        case .insert:
            "Veröffentlichen"
        case .update(_):
            "Aktualisieren"
        }
    }
}
