//
//  TypeDefinitions.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

// all cloud functions that i have written
enum CloudFunctionType {
    case addEvent
    case updateEvent
    
    var functionName: String {
        switch self {
        case .addEvent:
            return "addcalendareventv2"
        case .updateEvent:
            return "updatecalendareventv2"
        }
    }
    
}

// notification topics
enum SeesturmNotificationTopic: Identifiable {
    case schöpflialarm
    case schöpflialarmReaktion
    case aktuell
    case biberAktivitäten
    case wolfAktivitäten
    case pfadiAktivitäten
    case pioAktivitäten
    
    init(stufe: SeesturmStufeOld) {
        switch stufe {
        case .biber:
            self = .biberAktivitäten
        case .wolf:
            self = .wolfAktivitäten
        case .pfadi:
            self = .pfadiAktivitäten
        case .pio:
            self = .pioAktivitäten
        }
    }
    
    var id: UUID {
        switch self {
        case .schöpflialarm:
            UUID()
        case .schöpflialarmReaktion:
            UUID()
        case .aktuell:
            UUID()
        case .biberAktivitäten:
            UUID()
        case .wolfAktivitäten:
            UUID()
        case .pfadiAktivitäten:
            UUID()
        case .pioAktivitäten:
            UUID()
        }
    }
    
    var topicString: String {
        switch self {
        case .schöpflialarm:
            "schoepflialarm_v2"
        case .schöpflialarmReaktion:
            "schoepflialarmReaktion_v2"
        case .aktuell:
            "aktuell_v2"
        case .biberAktivitäten:
            "aktivitaetBiberstufe_v2"
        case .wolfAktivitäten:
            "aktivitaetWolfsstufe_v2"
        case .pfadiAktivitäten:
            "aktivitaetPfadistufe_v2"
        case .pioAktivitäten:
            "aktivitaetPiostufe_v2"
        }
    }
    
}


// stufen der pfadi seesturm
enum SeesturmStufeOld: Codable, Comparable, Hashable, CaseIterable {
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
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte Stufe.")
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
    var description: String {
        switch self {
        case .biber:
            return "Biberstufe"
        case .wolf:
            return "Wolfsstufe"
        case .pfadi:
            return "Pfadistufe"
        case .pio:
            return "Piostufe"
        }
    }
    var aktivitätDefaultDescription: String {
        switch self {
        case .biber:
            return "Biberstufen-Aktivität"
        case .wolf:
            return "Wolfsstufen-Aktivität"
        case .pfadi:
            return "Pfadistufen-Aktivität"
        case .pio:
            return "Piostufen-Aktivität"
        }
    }
    var calendar: SeesturmCalendar {
        switch self {
        case .biber:
            return .aktivitaetenBiberstufe
        case .wolf:
            return .aktivitaetenWolfsstufe
        case .pfadi:
            return .aktivitaetenPfadistufe
        case .pio:
            return .aktivitaetenPiostufe
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
            return Color.SEESTURM_RED
        case .wolf:
            return Color.wolfsstufeColor
        case .pfadi:
            return Color.SEESTURM_BLUE
        case .pio:
            return Color.SEESTURM_GREEN
        }
    }
    var allowedActionActivities: [AktivitaetAktion] {
        switch self {
        case .biber:
            return [.anmelden, .abmelden]
        case .wolf:
            return [.abmelden]
        case .pfadi:
            return [.abmelden]
        case .pio:
            return [.abmelden]
        }
    }
}

// aktivitäten erlaubte aktionen
enum AktivitaetAktion: CaseIterable, Identifiable, Codable {
    case anmelden
    case abmelden
    
    init(id: Int) throws {
        switch id {
        case 1:
            self = .anmelden
        case 0:
            self = .abmelden
        default:
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte An-/Abmelde-Art.")
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
    var icon: String {
        switch self {
        case .anmelden:
            return "checkmark.circle"
        case .abmelden:
            return "xmark.circle"
        }
    }
}

// aktivitäten erlaubte aktionen
enum AppMainTab {
    case home
    case aktuell
    case anlässe
    case mehr
    case account
    
    var id: Int {
        switch self {
        case .home:
            return 0
        case .aktuell:
            return 1
        case .anlässe:
            return 2
        case .mehr:
            return 3
        case .account:
            return 4
        }
    }
}

// allowed styles of button


// error types for network calls
enum PfadiSeesturmAppError: LocalizedError {
    
    case invalidUrl(message: String)
    case invalidResponse(message: String)
    case invalidData(message: String)
    case dateDecodingError(message: String)
    case invalidInput(message: String)
    case internetConnectionError(message: String)
    case cancellationError(message: String)
    case authError(message: String)
    case messagingPermissionError(message: String)
    case messagingError(message: String)
    case locationPermissionError(message: String)
    case locationAccuracyError(message: String)
    case locationError(message: String)
    case firestoreDocumentDoesNotExistError(message: String)
    case unknownError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidUrl(let message):
            return message
        case .invalidResponse(let message):
            return message
        case .invalidData(let message):
            return message
        case .dateDecodingError(let message):
            return message
        case .invalidInput(let message):
            return message
        case .internetConnectionError(let message):
            return message
        case .cancellationError(let message):
            return message
        case .authError(let message):
            return message
        case .messagingPermissionError(let message):
            return message
        case .messagingError(let message):
            return message
        case .locationPermissionError(let message):
            return message
        case .locationError(let message):
            return message
        case .locationAccuracyError(let message):
            return message
        case .firestoreDocumentDoesNotExistError(let message):
            return message
        case .unknownError(let message):
            return "Ein unbekannter Fehler ist aufgetreten: \(message)"
        }
    }
    
}



enum SeesturmLoadingState<Success, Failure: Error> {
    case none
    case loading
    case result(Result<Success, Failure>)
    case errorWithReload(error: PfadiSeesturmAppError)
}
extension SeesturmLoadingState {
    var userInteractionDisabled: Bool {
        switch self {
        case .loading, .result(.failure), .result(.success):
            return true
        default:
            return false
        }
    }
    var scrollingDisabled: Bool {
        switch self {
        case .loading, .errorWithReload(_), .none:
            return true
        default:
            return false
        }
    }
    var taskShouldRun: Bool {
        switch self {
        case .none, .errorWithReload(_):
            return true
        default:
            return false
        }
    }
    var infiniteScrollTaskShouldRun: Bool {
        switch self {
        case .none, .errorWithReload(_), .result(.success):
            return true
        default:
            return false
        }
    }
    var isError: Bool {
        switch self {
        case .result(.failure):
            return true
        default:
            return false
        }
    }
    var isSuccess: Bool {
        switch self {
        case .result(.success):
            return true
        default:
            return false
        }
    }
    func failureBinding(from publisher: Published<SeesturmLoadingState>.Publisher, reset: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: {
                if case .result(.failure) = self {
                    return true
                }
                return false
            },
            set: { _ in
                reset()
            }
        )
    }
    func successBinding(from publisher: Published<SeesturmLoadingState>.Publisher, reset: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: {
                if case .result(.success) = self {
                    return true
                }
                return false
            },
            set: { _ in
                reset()
            }
        )
    }
    func loadingBinding(from publisher: Published<SeesturmLoadingState>.Publisher) -> Binding<Bool> {
        Binding(
            get: {
                if case .loading = self {
                    return true
                }
                return false
            },
            set: { _ in }
        )
    }
    var errorMessage: String {
        switch self {
        case .result(.failure(let error)):
            return error.localizedDescription
        default:
            return "Ein Fehler ist aufgetreten"
        }
    }
    var successMessage: String {
        switch self {
        case .result(.success(let data)):
            if let message = data as? String {
                return message
            }
            else {
                return "Operation erfolgreich"
            }
        default:
            return ""
        }
    }
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}
extension Dictionary where Value == SeesturmLoadingState<String, PfadiSeesturmAppError> {
    var hasError: Bool {
        values.contains { state in
            if case .result(.failure) = state {
                return true
            } else {
                return false
            }
        }
    }
    var hasSuccess: Bool {
        values.contains { state in
            if case .result(.success) = state {
                return true
            } else {
                return false
            }
        }
    }
    var hasLoadingElement: Bool {
        values.contains { state in
            if case .loading = state {
                return true
            } else {
                return false
            }
        }
    }
    var firstErrorMessage: String {
        for state in values {
            switch state {
            case .result(.failure(let error)):
                return error.localizedDescription
            default:
                continue
            }
        }
        return "Ein Fehler is aufgetreten"
    }
    var firstSuccessMessage: String {
        for state in values {
            switch state {
            case .result(.success(let message)):
                return message
            default:
                continue
            }
        }
        return "Operation erfolgreich"
    }
}

enum SchöpflialarmResponseType {
    case unterwegs
    case heuteNicht
    case schonDa
    
    var id: Int {
        switch self {
        case .unterwegs:
            return 10
        case .heuteNicht:
            return 20
        case .schonDa:
            return 30
        }
    }
    
    init(id: Int) throws {
        switch id {
        case 10:
            self = .unterwegs
        case 20:
            self = .heuteNicht
        case 30:
            self = .schonDa
        default:
            throw PfadiSeesturmAppError.invalidInput(message: "Unbekannte Reaktions-Art für Schöpflialarm.")
        }
    }
    
}
