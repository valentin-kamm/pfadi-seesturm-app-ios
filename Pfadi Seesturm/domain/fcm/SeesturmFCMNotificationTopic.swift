//
//  SeesturmFCMNotificationTopic.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//
import SwiftUI

enum SeesturmFCMNotificationTopic: String, Identifiable, Codable, Equatable {
    
    case schoepflialarm = "schoepflialarm-2.0"
    case schoepflialarmReaction = "schoepflialarmReaction-2.0"
    case aktuell = "aktuell-2.0"
    case biberAktivitaeten = "aktivitaetBiberstufe-2.0"
    case wolfAktivitaeten = "aktivitaetWolfsstufe-2.0"
    case pfadiAktivitaeten = "aktivitaetPfadistufe-2.0"
    case pioAktivitaeten = "aktivitaetPiostufe-2.0"
    
    var id: Int {
        switch self {
        case .biberAktivitaeten:
            10
        case .wolfAktivitaeten:
            20
        case .pfadiAktivitaeten:
            30
        case .pioAktivitaeten:
            40
        case .aktuell:
            50
        case .schoepflialarm:
            100
        case .schoepflialarmReaction:
            110
        }
    }
    var topicName: String {
        switch self {
        case .schoepflialarm:
            "Schöpflialarm"
        case .schoepflialarmReaction:
            "Schöpflialarm Reaktionen"
        case .aktuell:
            "Aktuell"
        case .biberAktivitaeten:
            "Biberstufen-Aktivitäten"
        case .wolfAktivitaeten:
            "Wolfsstufen-Aktivitäten"
        case .pfadiAktivitaeten:
            "Pfadistufen-Aktivitäten"
        case .pioAktivitaeten:
            "Piostufen-Aktivitäten"
        }
    }
    var displayForAuthenticatedHitobitoUserOnly: Bool {
        switch self {
        case .schoepflialarm, .schoepflialarmReaction:
            true
        default:
            false
        }
    }
    
    init(topicString: String) throws {
        
        if let topic = SeesturmFCMNotificationTopic(rawValue: topicString) {
            self = topic
        }
        throw PfadiSeesturmError.unknownNotificationTopic(message: "Die Push-Nachricht kann keinen Thema zugeordnet werden.")
    }
    
    func navigationDestination(customKey: String?) -> (AppMainTab, NavigationPath)? {
        
        switch self {
        case .schoepflialarm, .schoepflialarmReaction:
            return (.account, NavigationPath())
        case .aktuell:
            guard let postId = Int(customKey ?? "") else {
                return nil
            }
            return (.aktuell, NavigationPath([AktuellNavigationDestination.detail(inputType: .id(id: postId))]))
        case .biberAktivitaeten, .wolfAktivitaeten, .pfadiAktivitaeten, .pioAktivitaeten:
            guard let eventId = customKey, let stufe = SeesturmStufe(topic: self) else {
                return nil
            }
            return (.home, NavigationPath([HomeNavigationDestination.aktivitaetDetail(inputType: .id(id: eventId), stufe: stufe)]))
        }
    }
}
