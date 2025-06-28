//
//  FCMRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import SwiftData

class FCMRepositoryImpl: FCMRepository {
    
    private let api: FCMApi
    private let modelContext: ModelContext
    
    init(
        api: FCMApi,
        modelContext: ModelContext
    ) {
        self.api = api
        self.modelContext = modelContext
    }
    
    func subscribeToTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await api.subscribeToFCMTopic(topic: topic)
        try insertLocalTopic(topic: topic)
    }
    
    func unsubscribeFromTopic(topic: SeesturmFCMNotificationTopic) async throws {
        try await api.unsubscribeFromFCMTopic(topic: topic)
        try deleteLocalTopic(topic: topic)
    }
    
    private func insertLocalTopic(topic: SeesturmFCMNotificationTopic) throws {
        
        modelContext.insert(
            SubscribedFCMNotificationTopicDao(topic: topic)
        )
        try modelContext.save()
    }
    
    private func deleteLocalTopic(topic: SeesturmFCMNotificationTopic) throws {
        
        let descriptor = FetchDescriptor<SubscribedFCMNotificationTopicDao>(
            predicate: SubscribedFCMNotificationTopicDao.topicFilter(topic: topic)
        )
        let daoToDelete = try modelContext.fetch(descriptor)
        if !daoToDelete.isEmpty {
            for dao in daoToDelete {
                modelContext.delete(dao)
            }
            try modelContext.save()
        }
    }
}
