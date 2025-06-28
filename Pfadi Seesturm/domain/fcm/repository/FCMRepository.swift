//
//  FCMRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//

protocol FCMRepository {
    
    func subscribeToTopic(topic: SeesturmFCMNotificationTopic) async throws
    func unsubscribeFromTopic(topic: SeesturmFCMNotificationTopic) async throws
}
