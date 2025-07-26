//
//  FCMService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import UserNotifications
import SwiftUI
import SwiftData

class FCMService {
    
    private let fcmRepository: FCMRepository
    private let firestoreRepository: FirestoreRepository
    private let notificationCenter: UNUserNotificationCenter
    
    init(
        repository: FCMRepository,
        firestoreRepository: FirestoreRepository,
        notificationCenter: UNUserNotificationCenter
    ) {
        self.fcmRepository = repository
        self.firestoreRepository = firestoreRepository
        self.notificationCenter = notificationCenter
    }
    
    func subscribe(to topic: SeesturmFCMNotificationTopic) async -> SeesturmResult<SeesturmFCMNotificationTopic, MessagingError> {
                
        do {
            try await requestOrCheckNotificationPermission()
            try await fcmRepository.subscribeToTopic(topic: topic)
            return .success(topic)
        }
        catch let error as PfadiSeesturmError {
            switch error {
            case .messagingPermissionError(_):
                return .error(.permissionError)
            default:
                return .error(.subscriptionFailed(topic: topic))
            }
        }
        catch {
            return .error(.subscriptionFailed(topic: topic))
        }
    }
    
    func unsubscribe(from topic: SeesturmFCMNotificationTopic) async -> SeesturmResult<SeesturmFCMNotificationTopic, MessagingError> {
        
        do {
            try await fcmRepository.unsubscribeFromTopic(topic: topic)
            return .success(topic)
        }
        catch {
            return .error(.unsubscriptionFailed(topic: topic))
        }
    }
    
    func requestOrCheckNotificationPermission() async throws {
        
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                if try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
                    print("Notification permission granted")
                }
                else {
                    throw PfadiSeesturmError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
                }
            }
            catch {
                throw PfadiSeesturmError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        case .denied:
            throw PfadiSeesturmError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
        case .authorized, .provisional, .ephemeral:
            print("Notification permission active")
        @unknown default:
            throw PfadiSeesturmError.unknown(message: "Unbekannter Fehler bei der Überprüfung der Einstellungen der Push-Nachrichten.")
        }
    }
    
    func goToAppSettings() {
        
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
    func updateFCMToken(for userId: String, newToken: String) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        do {
            try await firestoreRepository.performTransaction(
                type: FirebaseHitobitoUserDto.self,
                document: .user(id: userId),
                forceNewCreatedDate: false,
                update: { oldUser in
                    FirebaseHitobitoUserDto(
                        id: oldUser.id,
                        created: oldUser.created,
                        modified: oldUser.modified,
                        email: oldUser.email,
                        firstname: oldUser.firstname,
                        lastname: oldUser.lastname,
                        pfadiname: oldUser.pfadiname,
                        role: oldUser.role,
                        profilePictureUrl: oldUser.profilePictureUrl,
                        fcmToken: newToken
                    )
                }
            )
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
}
