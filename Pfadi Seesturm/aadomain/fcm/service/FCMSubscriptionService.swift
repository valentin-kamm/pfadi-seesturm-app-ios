//
//  FCMPushNotificationSubscriptionService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import UserNotifications

class FCMSubscriptionService {
    
    let repository: FCMRepository
    let notificationCenter: UNUserNotificationCenter
    init(
        repository: FCMRepository,
        notificationCenter: UNUserNotificationCenter
    ) {
        self.repository = repository
        self.notificationCenter = notificationCenter
    }
    
    func subscribe(to topic: SeesturmFCMNotificationTopic) async -> SeesturmResult<SeesturmFCMNotificationTopic, MessagingError> {
        do {
            try await requestOrCheckNotificationPermission()
            try await repository.subscribeToTopic(topic: topic)
            return .success(topic)
        }
        catch let error as PfadiSeesturmError {
            switch error {
            case .messagingPermissionError(_):
                return .error(.subscriptionFailed(topic: topic))
            default:
                return .error(.unknown)
            }
        }
        catch {
            return .error(.subscriptionFailed(topic: topic))
        }
    }
    func unsubscribe(from topic: SeesturmFCMNotificationTopic) async -> SeesturmResult<SeesturmFCMNotificationTopic, MessagingError> {
        do {
            try await repository.unsubscribeFromTopic(topic: topic)
            return .success(topic)
        }
        catch {
            return .error(.unsubscriptionFailed(topic: topic))
        }
    }
    
    private func requestOrCheckNotificationPermission() async throws {
        
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
}
