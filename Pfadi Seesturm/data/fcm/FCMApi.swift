//
//  FCMApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import FirebaseMessaging

protocol FCMApi {
    
    func subscribeToFCMTopic(topic: SeesturmFCMNotificationTopic) async throws
    func unsubscribeFromFCMTopic(topic: SeesturmFCMNotificationTopic) async throws
}

class FCMApiImpl: FCMApi {
    
    private let messaging: Messaging
    
    init(messaging: Messaging) {
        self.messaging = messaging
    }
    
    func subscribeToFCMTopic(topic: SeesturmFCMNotificationTopic) async throws -> Void {
        try await messaging.subscribe(toTopic: topic.rawValue)
    }
    
    func unsubscribeFromFCMTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await messaging.unsubscribe(fromTopic: topic.rawValue)
    }
}
