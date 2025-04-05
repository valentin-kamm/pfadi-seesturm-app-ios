//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import Foundation
import SwiftData

@Model
final class SubscribedFCMNotificationTopicDao {
    
    private var topicRaw: SeesturmFCMNotificationTopic.RawValue
    
    init(topic: SeesturmFCMNotificationTopic) {
        self.topicRaw = topic.rawValue
    }
    
    func getTopic() throws -> SeesturmFCMNotificationTopic {
        guard let validTopic = SeesturmFCMNotificationTopic(rawValue: topicRaw) else {
            throw PfadiSeesturmError.unknownNotificationTopic(message: "FCM topic \(topicRaw) unbekannt.")
        }
        return validTopic
    }
    func setTopic(topic: SeesturmFCMNotificationTopic) {
        topicRaw = topic.rawValue
    }
    
    static func topicFilter(topic: SeesturmFCMNotificationTopic) -> Predicate<SubscribedFCMNotificationTopicDao> {
        return #Predicate<SubscribedFCMNotificationTopicDao> {
            $0.topicRaw == topic.rawValue
        }
    }
}
