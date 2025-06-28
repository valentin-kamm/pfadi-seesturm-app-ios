//
//  SeesturmFCMNotificationType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//

enum SeesturmFCMNotificationType {
    
    case schoepflialarmCustom(userName: String, body: String)
    case schoepflialarmGeneric(userName: String)
    
    case schoepflialarmReactionGeneric(userName: String, type: SchoepflialarmReactionType)
    
    case aktivitaetNew(stufe: SeesturmStufe, eventId: String)
    case aktivitaetUpdate(stufe: SeesturmStufe, eventId: String)
    case aktivitaetGeneric(stufe: SeesturmStufe, eventId: String)
    
    case aktuellGeneric(title: String, body: String, postId: String)
    
    var topic: SeesturmFCMNotificationTopic {
        switch self {
        case .schoepflialarmCustom(_, _), .schoepflialarmGeneric(_):
            .schoepflialarm
        case .schoepflialarmReactionGeneric(_, _):
            .schoepflialarmReaction
        case .aktivitaetNew(let stufe, _), .aktivitaetUpdate(let stufe, _), .aktivitaetGeneric(let stufe, _):
            stufe.aktivitaetNotificationTopic
        case .aktuellGeneric(_, _, _):
            .aktuell
        }
    }
    
    var content: SeesturmFCMNotificationContent {
        switch self {
        case .schoepflialarmCustom(let userName, let body):
            SeesturmFCMNotificationContent(
                title: "\(userName) hat einen Schöpflialarm ausgelöst!",
                body: body,
                customKey: nil
            )
        case .schoepflialarmGeneric(let userName):
            SeesturmFCMNotificationContent(
                title: "\(userName) hat einen Schöpflialarm ausgelöst!",
                body: "Bitte umgehend im Schöpfli erscheinen.",
                customKey: nil
            )
        case .schoepflialarmReactionGeneric(let userName, let type):
            switch type {
            case .coming:
                SeesturmFCMNotificationContent(
                    title: "Schöpflialarm",
                    body: "\(userName) ist auf dem Weg!",
                    customKey: nil
                )
            case .notComing:
                SeesturmFCMNotificationContent(
                    title: "Schöpflialarm",
                    body: "\(userName) kommt nicht!",
                    customKey: nil
                )
            case .alreadyThere:
                SeesturmFCMNotificationContent(
                    title: "Schöpflialarm",
                    body: "\(userName) ist schon da!",
                    customKey: nil
                )
            }
        case .aktivitaetNew(let stufe, let eventId):
            SeesturmFCMNotificationContent(
                title: "\(stufe.aktivitaetDescription) veröffentlicht",
                body: "Die Infos zur \(stufe.aktivitaetDescription) sind online.",
                customKey: eventId
            )
        case .aktivitaetUpdate(let stufe, let eventId):
            SeesturmFCMNotificationContent(
                title: "\(stufe.aktivitaetDescription) aktualisiert",
                body: "Die Infos zur \(stufe.aktivitaetDescription) wurden aktualisiert.",
                customKey: eventId
            )
        case .aktivitaetGeneric(let stufe, let eventId):
            SeesturmFCMNotificationContent(
                title: "\(stufe.aktivitaetDescription) veröffentlicht oder aktualisiert",
                body: "Infos zur einer \(stufe.aktivitaetDescription) veröffentlicht oder aktualisiert.",
                customKey: eventId
            )
        case .aktuellGeneric(let title, let body, let postId):
            SeesturmFCMNotificationContent(
                title: title,
                body: body,
                customKey: postId
            )
        }
    }
}
