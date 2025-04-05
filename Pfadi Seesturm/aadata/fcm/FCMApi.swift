//
//  FCMApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import FirebaseMessaging

protocol FCMApi {
    
    func subscribeToTopic(topic: SeesturmFCMNotificationTopic) async throws
    func unsubscribeFromTopic(topic: SeesturmFCMNotificationTopic) async throws
        
    func sendPushNotification(topic: SeesturmFCMNotificationTopic) async throws
    
}

class FCMApiImpl: FCMApi {
    
    let messaging: Messaging
    
    init(messaging: Messaging) {
        self.messaging = messaging
    }
    
    func subscribeToTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await messaging.subscribe(toTopic: topic.topicString)
    }
    func unsubscribeFromTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await messaging.unsubscribe(fromTopic: topic.topicString)
    }
    
    func sendPushNotification(topic: SeesturmFCMNotificationTopic) async throws {
        
    }
}
