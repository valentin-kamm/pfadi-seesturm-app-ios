//
//  SeesturmStufe.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import SwiftUI

enum SeesturmStufe: String, Codable, Hashable, CaseIterable, Identifiable {
    
    case biber
    case wolf
    case pfadi
    case pio
    
    init(id: Int) throws {
        switch id {
        case 0:
            self = .biber
        case 1:
            self = .wolf
        case 2:
            self = .pfadi
        case 3:
            self = .pio
        default:
            throw PfadiSeesturmError.unknownStufe(message: "Unbekannte Stufe.")
        }
    }
    
    init?(topic: SeesturmFCMNotificationTopic) {
        switch topic {
        case .schoepflialarm, .schoepflialarmReaction, .aktuell:
            return nil
        case .biberAktivitaeten:
            self = .biber
        case .wolfAktivitaeten:
            self = .wolf
        case .pfadiAktivitaeten:
            self = .pfadi
        case .pioAktivitaeten:
            self = .pio
        }
    }
    
    var id: Int {
        switch self {
        case .biber:
            return 0
        case .wolf:
            return 1
        case .pfadi:
            return 2
        case .pio:
            return 3
        }
    }
    
    var name: String {
        switch self {
        case .biber:
            "Biberstufe"
        case .wolf:
            "Wolfsstufe"
        case .pfadi:
            "Pfadistufe"
        case .pio:
            "Piostufe"
        }
    }
    
    var aktivitaetDescription: String {
        switch self {
        case .biber:
            "Biberstufen-Aktivität"
        case .wolf:
            "Wolfsstufen-Aktivität"
        case .pfadi:
            "Pfadistufen-Aktivität"
        case .pio:
            "Piostufen-Aktivität"
        }
    }
    
    var calendar: SeesturmCalendar {
        switch self {
        case .biber:
            .aktivitaetenBiberstufe
        case .wolf:
            .aktivitaetenWolfsstufe
        case .pfadi:
            .aktivitaetenPfadistufe
        case .pio:
            .aktivitaetenPiostufe
        }
    }
    
    var icon: Image {
        switch self {
        case .biber:
            return Image("biber")
        case .wolf:
            return Image("wolf")
        case .pfadi:
            return Image("pfadi")
        case .pio:
            return Image("pio")
        }
    }
    
    var color: Color {
        switch self {
        case .biber:
            Color.SEESTURM_RED
        case .wolf:
            Color.SEESTURM_YELLOW
        case .pfadi:
            Color.SEESTURM_BLUE
        case .pio:
            Color.SEESTURM_GREEN
        }
    }
    
    var highContrastColor: Color {
        switch self {
        case .biber:
            Color.SEESTURM_RED
        case .wolf:
            Color.wolfsstufeColor
        case .pfadi:
            Color.SEESTURM_BLUE
        case .pio:
            Color.SEESTURM_GREEN
        }
    }
    
    var onHighContrastColor: Color {
        switch self {
        case .biber, .pfadi, .pio:
            .white
        case .wolf:
            .customBackground
        }
    }
    
    var allowedAktivitaetInteractions: [AktivitaetInteractionType] {
        switch self {
        case .biber:
            [.abmelden, .anmelden]
        case .wolf:
            [.abmelden]
        case .pfadi:
            [.abmelden]
        case .pio:
            [.abmelden]
        }
    }
    
    var aktivitaetNotificationTopic: SeesturmFCMNotificationTopic {
        switch self {
        case .biber:
            .biberAktivitaeten
        case .wolf:
            .wolfAktivitaeten
        case .pfadi:
            .pfadiAktivitaeten
        case .pio:
            .pioAktivitaeten
        }
    }
}

extension [SeesturmStufe] {
    
    var stufenDropdownText: String {
        switch self.count {
        case 0:
            "Wählen"
        case 1:
            self.first?.name ?? "Wählen"
        case 4:
            "Alle"
        default:
            "Mehrere"
        }
    }
}
