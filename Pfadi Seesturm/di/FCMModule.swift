//
//  FCMModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import SwiftUI
import FirebaseMessaging
import SwiftData

protocol FCMModule {
        
    var fcmApi: FCMApi { get }
    var fcmRepository: FCMRepository { get }
    var fcmService: FCMService { get }
}

class FCMModuleImpl: FCMModule {

    private let messaging: Messaging
    private let notificationCenter: UNUserNotificationCenter
    private let modelContext: ModelContext
    private let firestoreRepository: FirestoreRepository
    init(
        messaging: Messaging = Messaging.messaging(),
        notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current(),
        modelContext: ModelContext,
        firestoreRepository: FirestoreRepository
    ) {
        self.messaging = messaging
        self.notificationCenter = notificationCenter
        self.modelContext = modelContext
        self.firestoreRepository = firestoreRepository
    }
    
    lazy var fcmApi: FCMApi = FCMApiImpl(messaging: messaging)
    
    lazy var fcmRepository: FCMRepository = FCMRepositoryImpl(
        api: fcmApi,
        modelContext: modelContext
    )
    
    lazy var fcmService: FCMService = FCMService(
        repository: fcmRepository,
        firestoreRepository: firestoreRepository,
        notificationCenter: notificationCenter,
    )
}

struct FCMModuleKey: EnvironmentKey {
    static let defaultValue: FCMModule = FCMModuleImpl(
        messaging: Messaging.messaging(),
        notificationCenter: UNUserNotificationCenter.current(),
        modelContext: ModelContext(seesturmModelContainer),
        firestoreRepository: FirestoreRepositoryImpl(
            db: .firestore(),
            api: FirestoreApiImpl(
                db: .firestore()
            )
        )
    )
}
extension EnvironmentValues {
    var fcmModule: FCMModule {
        get { self[FCMModuleKey.self] }
        set { self[FCMModuleKey.self] = newValue }
    }
}
