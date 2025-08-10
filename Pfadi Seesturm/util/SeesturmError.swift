//
//  SeesturmError.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import Foundation

protocol SeesturmError {
    var defaultMessage: String { get }
}

protocol DataError: SeesturmError { }

enum SchoepflialarmError: SeesturmError {
    
    case tooFarAway(message: String)
    case tooEarly(message: String)
    case messagingPermissionMissing
    case locationError(message: String)
    case locationPermissionMissing
    case unknown(message: String)
    
    var defaultMessage: String {
        switch self {
        case .tooFarAway(message: let message):
            message
        case .tooEarly(message: let message):
            message
        case .messagingPermissionMissing:
            "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren."
        case .locationError(let message):
            message
        case .locationPermissionMissing:
            "Um diese Funktion zu nutzen, müssen die Ortungsdienste aktiviert sein."
        case .unknown(message: let message):
            message
        }
    }
}

enum CloudFunctionsError: DataError {
    
    case invalidPayload
    case invalidResponse
    case unknown(message: String)
    
    var defaultMessage: String {
        switch self {
        case .invalidPayload:
            "Die gesendeten Daten sind ungültig."
        case .invalidResponse:
            "Die empfangenen Daten sind ungültig."
        case .unknown(let message):
            "Unbekannter Fehler: \(message)"
        }
    }
}

enum NetworkError: DataError {
    
    case unknown
    case invalidUrl
    case invalidDate
    case invalidData
    case ioException
    case cancelled
    case invalidWeatherCondition
    case invalidRequest(httpCode: Int)

    var defaultMessage: String {
        switch self {
        case .unknown:
            return "Unbekannter Netzwerkfehler."
        case .invalidUrl:
            return "Die URL ist ungültig."
        case .invalidDate:
            return "Ungültiges Datumsformat in den vom Server bereitgestellten Daten."
        case .invalidData:
            return "Die vom Server bereitgestellten Daten sind ungültig."
        case .ioException:
            return "Überprüfe deine Internetverbindung und versuche es erneut."
        case .cancelled:
            return "Die Operation wurde abgebrochen."
        case .invalidWeatherCondition:
            return "Die Wetterbedingung ist unbekannt."
        case .invalidRequest(let httpCode):
            return "Die Operation ist mit dem Code \(httpCode) fehlgeschlagen."
        }
    }
}

enum RemoteDatabaseError: DataError {
    
    case savingError
    case decodingError
    case readingError
    case documentDoesNotExist
    case deletingError
    case unknown
    
    var defaultMessage: String {
        switch self {
        case .savingError:
            "Die Daten konnten nicht gespeichert werden."
        case .decodingError:
            "Die Daten sind ungültig und können nicht decodiert werden."
        case .readingError:
            "Die Daten konnten nicht gelesen werden."
        case .documentDoesNotExist:
            "Dokument existiert nicht."
        case .deletingError:
            "Dokument konnte nicht gelöscht werden."
        case .unknown:
            "Unbekannter Fehler beim Bearbeiten der Daten."
        }
    }
}

enum LocalError: DataError {
    
    case unknown
    case savingError
    case readingError
    case deletingError
    case invalidDate
    case invalidFormInput

    var defaultMessage: String {
        switch self {
        case .unknown:
            return "Unbekannter Fehler beim Bearbeiten der Daten."
        case .savingError:
            return "Die Daten sind fehlerhaft und konnten nicht gespeichert werden."
        case .readingError:
            return "Die Daten sind fehlerhaft und konnten nicht gelesen werden."
        case .deletingError:
            return "Der Datensatz konnte nicht gelöscht werden."
        case .invalidDate:
            return "Ungültiges Datumsformat."
        case .invalidFormInput:
            return "Die eingegebenen Daten sind unvollständig."
        }
    }
}

enum MessagingError: SeesturmError {
    
    case unknown
    case permissionError
    case subscriptionFailed(topic: SeesturmFCMNotificationTopic)
    case unsubscriptionFailed(topic: SeesturmFCMNotificationTopic)
    case sendingError(topic: SeesturmFCMNotificationTopic)
    
    var defaultMessage: String {
        switch self {
        case .permissionError:
            "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren."
        case .subscriptionFailed(let topic):
            "Anmeldung für \(topic.topicName) fehlgeschlagen."
        case .unsubscriptionFailed(let topic):
            "Abmeldung von \(topic.topicName) fehlgeschlagen."
        case .sendingError(let topic):
            "Die Push-Nachricht für \(topic.topicName) konnte nicht gesendet werden."
        case .unknown:
            "Beim Bearbeiten von Push-Nachrichten ist ein unbekannter Fehler aufgetreten."
        }
    }
}

enum AuthError: SeesturmError {
    
    case unknown(message: String)
    case signInError(message: String)
    case signOutError(message: String)
    case deleteAccountError(message: String)
    case cancelled
    
    var defaultMessage: String {
        switch self {
        case .signInError(let message):
            message
        case .signOutError(let message):
            message
        case .cancelled:
            "Anmeldeprozess durch Benutzer abgebrochen."
        case .deleteAccountError(let message):
            "Der Account konnte nicht gelöscht werden. Versuche es später erneut. \(message)"
        case .unknown(let message):
            message
        }
    }
}

enum SchoepflialarmLocalizedError: LocalizedError {
    
    case tooFarAway(distanceDescription: String)
    case tooEarly(message: String)
    case locationError(message: String)
    case locationPermissionError
    case unknown(message: String)
    
    func toSchoepflialarmError() -> SchoepflialarmError {
        switch self {
        case .tooEarly(let message):
            return .tooEarly(message: message)
        case .tooFarAway(let distanceDescription):
            let message = "Du befindest dich \(distanceDescription) vom Schöpfli entfernt und kannst somit keinen Schöpflialarm auslösen."
            return .tooFarAway(message: message)
        case .locationError(let message):
            return .locationError(message: message)
        case .locationPermissionError:
            return .locationPermissionMissing
        case .unknown(let message):
            return .unknown(message: message)
        }
    }
}

// error types for network calls
enum PfadiSeesturmError: LocalizedError {
    
    case invalidHttpResponse(code: Int, message: String)
    case invalidResponse(message: String)
    case invalidUrl(message: String)
    case dateError(message: String)
    case messagingPermissionError(message: String)
    case unknownStufe(message: String)
    case unknownNotificationTopic(message: String)
    case unknownAktivitaetInteraction(message: String)
    case authError(message: String)
    case cancelled(message: String)
    case unknownSchoepflialarmReactionType(message: String)
    case jpgConversionFailed(message: String)
    case unknown(message: String)
        
    var errorDescription: String? {
        switch self {
        case .invalidHttpResponse(let code, let message):
            return "\(message) (Code \(code))"
        case .invalidUrl(let message):
            return message
        case .invalidResponse(let message):
            return message
        case .dateError(let message):
            return message
        case .messagingPermissionError(let message):
            return message
        case .unknownStufe(let message):
            return message
        case .unknownNotificationTopic(let message):
            return message
        case .unknownAktivitaetInteraction(let message):
            return message
        case .authError(let message):
            return message
        case .cancelled(let message):
            return message
        case .unknownSchoepflialarmReactionType(let message):
            return message
        case .jpgConversionFailed(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}
