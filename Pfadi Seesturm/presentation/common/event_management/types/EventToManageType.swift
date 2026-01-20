//
//  EventToManageType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.01.2026.
//
import SwiftUI

enum EventToManageType: Hashable {
    
    case aktivitaet(stufe: SeesturmStufe, mode: EventManagementMode)
    case multipleAktivitaeten
    case termin(calendar: SeesturmCalendar, mode: EventManagementMode)
    
    var templatesNavigationTitle: String {
        switch self {
        case .aktivitaet(let stufe, _):
            "Vorlagen \(stufe.name)"
        case .multipleAktivitaeten, .termin(_, _):
            "Vorlagen"
        }
    }
        
    var accentColor: Color {
        switch self {
        case .aktivitaet(let stufe, _):
            stufe.highContrastColor
        case .multipleAktivitaeten:
            .SEESTURM_GREEN
        case .termin(let calendar, _):
            calendar.isLeitungsteam ? .SEESTURM_RED : .SEESTURM_GREEN
        }
    }
        
    var onAccentColor: Color {
        switch self {
        case .aktivitaet(let stufe, _):
            stufe.onHighContrastColor
        case .multipleAktivitaeten, .termin(_, _):
            .white
        }
    }
        
    var titlePlaceholder: String {
        switch self {
        case .aktivitaet(let stufe, _):
            stufe.aktivitaetDescription
        case .multipleAktivitaeten:
            "Titel der Aktivität"
        case .termin(_, _):
            "Titel des Anlass"
        }
    }
        
    var navigationTitle: String {
        switch self {
        case .aktivitaet(let stufe, let mode):
            switch mode {
            case .insert:
                "Neue \(stufe.aktivitaetDescription)"
            case .update(_):
                "\(stufe.aktivitaetDescription) bearbeiten"
            }
        case .multipleAktivitaeten:
            "Neue Aktivität"
        case .termin(_, let mode):
            switch mode {
            case .insert:
                "Neuer Anlass"
            case .update(_):
                "Anlass bearbeiten"
            }
        }
    }
}
