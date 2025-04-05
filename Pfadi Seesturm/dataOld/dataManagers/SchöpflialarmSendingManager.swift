//
//  SchöpflialarmManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2024.
//

import Foundation

class SchöpflialarmSendingManager {
    
    /*
    
    let message: String
    let user: FirebaseHitobitoUser
    
    init(
        message: String,
        user: FirebaseHitobitoUser
    ) {
        self.message = message
        self.user = user
    }
    
    // function to send a schöpflialarm reaction
    func sendSchöpflialarmReaction() async {
        // TODO: - implement
    }
    
    // function to send schöpflialarm
    @MainActor
    func sendSchöpflialarm(
        showNotificationsSettingsAlert: () -> Void,
        showLocationSettingsAlert:  () -> Void,
        showLocationAccuracySettingsAlert:  () -> Void,
        onNewState: (SeesturmLoadingState<String, PfadiSeesturmAppError>) -> Void
    ) async {
        do {
            try await FCMManager.shared.requestOrCheckNotificationPermission()
            onNewState(.loading)
            try await LeiterbereichLocationManager().checkUserLocation()
            try await checkLastSchöpflialarmTime()
            try await saveSchöpflialarm()
            onNewState(.result(.success("Schöpflialarm erfolgreich gesendet.")))
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .messagingPermissionError = pfadiSeesturmError {
                onNewState(.none)
                showNotificationsSettingsAlert()
            }
            else if case .locationPermissionError = pfadiSeesturmError {
                onNewState(.none)
                showLocationSettingsAlert()
            }
            else if case .locationAccuracyError = pfadiSeesturmError {
                onNewState(.none)
                showLocationAccuracySettingsAlert()
            }
            else {
                onNewState(.result(.failure(pfadiSeesturmError)))
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
            onNewState(.result(.failure(pfadiSeesturmError)))
        }
        
    }
    
    // function that actually writes the new schöpflialarm to firestore
    private func saveSchöpflialarm() async throws {
        let payload = Schöpflialarm(
            message: message.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "Bitte umgehend im Schöpfli erscheinen." : message,
            userId: Int(user.userId)!,
            responses: []
        )
        let docRef = FirestoreManager.FirestoreStructure.FirestoreLeiterbereichCollection.FirestoreSchopflialarmDocument.document
        try await FirestoreManager.shared.updateFirestoreDocument(object: payload, documentReference: docRef)
    }
    
    /*
    // function to check last schöpflialarm time
    private func checkLastSchöpflialarmTime() async throws {
        do {
            let docRef = FirestoreManager.FirestoreStructure.FirestoreLeiterbereichCollection.FirestoreSchopflialarmDocument.document
            let createdDate = try await FirestoreManager.shared.readSingleDocument(documentReference: docRef, as: Schöpflialarm.self).getCreatedDate()
            let timeDifference = abs(Date().timeIntervalSince(createdDate))
            if timeDifference < 3600 {
                throw PfadiSeesturmAppError.messagingError(message: "Schöpflialarm wurde bereits ausgelöst. Es ist nur ein Schöpflialarm pro Stunde erlaubt.")
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .firestoreDocumentDoesNotExistError = pfadiSeesturmError {
                // do nothing
            }
            else {
                throw pfadiSeesturmError
            }
        }
        catch {
            throw error
        }
    }
     */
     */
    
}
