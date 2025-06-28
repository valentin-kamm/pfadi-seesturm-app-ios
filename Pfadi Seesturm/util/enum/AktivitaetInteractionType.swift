//
//  AktivitaetInteractionType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import SwiftUI

enum AktivitaetInteractionType: CaseIterable, Identifiable, Codable {
    
    case anmelden
    case abmelden
    
    init(id: Int) throws {
        switch id {
        case 1:
            self = .anmelden
        case 0:
            self = .abmelden
        default:
            throw PfadiSeesturmError.unknownAktivitaetInteraction(message: "Unbekannte An-/Abmelde-Art.")
        }
    }
    
    var id: Int {
        switch self {
        case .anmelden:
            return 1
        case .abmelden:
            return 0
        }
    }
    
    var nomen: String {
        switch self {
        case .anmelden:
            return "Anmeldung"
        case .abmelden:
            return "Abmeldung"
        }
    }
    
    var nomenMehrzahl: String {
        switch self {
        case .anmelden:
            return "Anmeldungen"
        case .abmelden:
            return "Abmeldungen"
        }
    }
    
    var verb: String {
        switch self {
        case .anmelden:
            return "anmelden"
        case .abmelden:
            return "abmelden"
        }
    }
    
    var taetigkeit: String {
        switch self {
        case .anmelden:
            return "Angemeldet"
        case .abmelden:
            return "Abgemeldet"
        }
    }
    
    var icon: String {
        switch self {
        case .anmelden:
            return "checkmark.circle"
        case .abmelden:
            return "xmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .anmelden:
            return Color.SEESTURM_GREEN
        case .abmelden:
            return Color.SEESTURM_RED
        }
    }
}
