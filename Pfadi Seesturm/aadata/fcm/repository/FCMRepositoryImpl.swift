//
//  FCMRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//

class FCMRepositoryImpl: FCMRepository {
    
    let api: FCMApi
    init(api: FCMApi) {
        self.api = api
    }
    
    func subscribeToTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await api.subscribeToTopic(topic: topic)
    }
    func unsubscribeFromTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await api.unsubscribeFromTopic(topic: topic)
    }
    
    func sendPushNotification(topic: SeesturmFCMNotificationTopic) async throws {
        
    }
}
