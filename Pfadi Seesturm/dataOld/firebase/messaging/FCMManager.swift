//
//  FCMManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import SwiftUI
import UserNotifications
import FirebaseMessaging

class FCMManager {
    
    static let shared = FCMManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // function to send a push notification
    func sendPushNotification(payload: PushNotificationPayload) async throws {
        
    }
    
    // function to construct a push notification payload
    func constructPushNotificationPayload(topic: SeesturmNotificationTopic) -> PushNotificationPayload {
        return PushNotificationPayload()
    }
    
    // function to subscribe to FCM topic
    func subscribe(to topic: SeesturmNotificationTopic) async throws {
        try await Messaging.messaging().subscribe(toTopic: topic.topicString)
    }
    func unsubscribe(from topic: SeesturmNotificationTopic) async throws {
        try await Messaging.messaging().unsubscribe(fromTopic: topic.topicString)
    }
    
    // function to check if the user has allowed to receive notifications
    func requestOrCheckNotificationPermission() async throws {
        let settings = await notificationCenter.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                if try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) {
                    print("Notification permission granted")
                }
                else {
                    throw PfadiSeesturmAppError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
                }
            }
            catch {
                throw PfadiSeesturmAppError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        case .denied:
            throw PfadiSeesturmAppError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
        case .authorized, .provisional, .ephemeral:
            print("Notification permission active")
        @unknown default:
            throw PfadiSeesturmAppError.messagingPermissionError(message: "Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
        }
    }
    
    // function that displays an alert telling the user to turn in notifications in settings
    func goToNotificationSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
    
}
