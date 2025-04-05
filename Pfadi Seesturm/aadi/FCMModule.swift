//
//  FCMModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import SwiftUI
import FirebaseMessaging

protocol FCMModule {
    
    var notificationCenter: UNUserNotificationCenter { get }
    var messaging: Messaging { get }
    
    var fcmApi: FCMApi { get }
    
    var fcmRepository: FCMRepository { get }
    
    var fcmSubscriptionService: FCMSubscriptionService { get }
}

class FCMModuleImpl: FCMModule {

    var messaging: Messaging
    var notificationCenter: UNUserNotificationCenter
    init(
        messaging: Messaging,
        notificationCenter: UNUserNotificationCenter
    ) {
        self.messaging = messaging
        self.notificationCenter = notificationCenter
    }
    
    lazy var fcmApi: FCMApi = FCMApiImpl(messaging: messaging)
    
    lazy var fcmRepository: FCMRepository = FCMRepositoryImpl(api: fcmApi)
    
    lazy var fcmSubscriptionService: FCMSubscriptionService = FCMSubscriptionService(
        repository: fcmRepository,
        notificationCenter: notificationCenter
    )
}

struct FCMModuleKey: EnvironmentKey {
    static let defaultValue: FCMModule = FCMModuleImpl(
        messaging: Messaging.messaging(),
        notificationCenter: UNUserNotificationCenter.current()
    )
}
extension EnvironmentValues {
    var fcmModule: FCMModule {
        get { self[FCMModuleKey.self] }
        set { self[FCMModuleKey.self] = newValue }
    }
}
