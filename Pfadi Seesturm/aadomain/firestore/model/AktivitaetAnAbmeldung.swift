//
//  AktivitaetAnAbmeldung.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import Foundation

struct AktivitaetAnAbmeldung: Identifiable, Hashable {
    var id: String
    var eventId: String
    var uid: String?
    var vorname: String
    var nachname: String
    var pfadiname: String?
    var bemerkung: String?
    var type: AktivitaetInteraction
    var stufe: SeesturmStufe
    var created: Date
    var modified: Date
    var createdString: String
    var modifiedString: String
}

extension AktivitaetAnAbmeldung {
    var displayName: String {
        if let pn = pfadiname {
            return "\(vorname) \(nachname) / \(pn)"
        }
        return "\(vorname) \(nachname)"
    }
    var bemerkungForDisplay: String {
        if let b = bemerkung {
            return "Bemerkung: \(b)"
        }
        else {
            return "Bemerkung: -"
        }
    }
}
