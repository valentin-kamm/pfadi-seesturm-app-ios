//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation
import SwiftUI

// auth state
enum AuthState {
    case signedOut(state: ActionState<Void>)
    case signedInWithHitobito(user: FirebaseHitobitoUser, state: ActionState<Void>, leiterbereichViewMode: LeiterbereichViewModel)
}
extension AuthState {
    var showInfoSnackbar: Bool {
        switch self {
        case .signedOut(let state):
            switch state {
            case .idle:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    var signInButtonIsLoading: Bool {
        switch self {
        case .signedOut(let state):
            switch state {
            case .loading(_):
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

// stufen der pfadi seesturm
enum SeesturmStufe: String, Codable, Hashable, CaseIterable {
    
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
    var stufenName: String {
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
            Color.primary
        case .pfadi:
            Color.SEESTURM_BLUE
        case .pio:
            Color.SEESTURM_GREEN
        }
    }
    var allowedAktivitaetInteractions: [AktivitaetInteraction] {
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
}
enum AktivitaetInteraction: CaseIterable, Identifiable, Codable {
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

enum SeesturmFCMNotificationTopic: String, Identifiable, Codable {
    case schöpflialarm
    case schöpflialarmReaktion
    case aktuell
    case biberAktivitäten
    case wolfAktivitäten
    case pfadiAktivitäten
    case pioAktivitäten
}
extension SeesturmFCMNotificationTopic {
    var id: Int {
        switch self {
        case .schöpflialarm:
            100
        case .schöpflialarmReaktion:
            110
        case .aktuell:
            50
        case .biberAktivitäten:
            10
        case .wolfAktivitäten:
            20
        case .pfadiAktivitäten:
            30
        case .pioAktivitäten:
            40
        }
    }
    
    var topicString: String {
        switch self {
        case .schöpflialarm:
            "schoepflialarm-v2"
        case .schöpflialarmReaktion:
            "schoepflialarmReaktion-v2"
        case .aktuell:
            "aktuell-v2"
        case .biberAktivitäten:
            "aktivitaetBiberstufe-v2"
        case .wolfAktivitäten:
            "aktivitaetWolfsstufe-v2"
        case .pfadiAktivitäten:
            "aktivitaetPfadistufe-v2"
        case .pioAktivitäten:
            "aktivitaetPiostufe-v2"
        }
    }
    
    var topicName: String {
        switch self {
        case .schöpflialarm:
            "Schöpflialarm"
        case .schöpflialarmReaktion:
            "Schöpflialarm Reaktionen"
        case .aktuell:
            "Aktuell"
        case .biberAktivitäten:
            "Biberstufen-Aktivitäten"
        case .wolfAktivitäten:
            "Wolfsstufen-Aktivitäten"
        case .pfadiAktivitäten:
            "Pfadistufen-Aktivitäten"
        case .pioAktivitäten:
            "Piostufen-Aktivitäten"
        }
    }
}


struct CalendarData {
    let calendarId: String
    let subscriptionUrl: URL
}
enum SeesturmCalendar {
    case termine
    case termineLeitungsteam
    case aktivitaetenBiberstufe
    case aktivitaetenWolfsstufe
    case aktivitaetenPfadistufe
    case aktivitaetenPiostufe
    
    var data: CalendarData {
        switch self {
        case .termine:
            return CalendarData(
                calendarId: "app@seesturm.ch",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/app%40seesturm.ch/public/basic.ics")!
            )
        case .termineLeitungsteam:
            return CalendarData(
                calendarId: "5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenBiberstufe:
            return CalendarData(
                calendarId: "c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenWolfsstufe:
            return CalendarData(
                calendarId: "c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPfadistufe:
            return CalendarData(
                calendarId: "c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPiostufe:
            return CalendarData(
                calendarId: "c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25%40group.calendar.google.com/public/basic.ics")!
            )
        }
    }
    
    var isLeitungsteam: Bool {
        switch self {
        case .termineLeitungsteam:
            return true
        default:
            return false
        }
    }
}

struct FormSection: Hashable, Identifiable {
    var id = UUID()
    var header: String
    var footer: String
    var order: Int
}
