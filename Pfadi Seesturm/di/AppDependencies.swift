//
//  AppDependencies.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.03.2025.
//
import FirebaseMessaging
import FirebaseAuth
import SwiftData
import FirebaseCore
import FirebaseAppCheck

@MainActor
final class AppDependencies {
    
    private let modelContext: ModelContext
    
    let authModule: AuthModule
    let fcmModule: FCMModule
    let firestoreModule: FirestoreModule
    let wordpressModule: WordpressModule
    let fcfModule: FCFModule
    let appState: AppStateViewModel
    let storageModule: StorageModule
    let accountModule: AccountModule
    let notificationHandler: NotificationHandler
    
    init(
        modelContext: ModelContext
    ) {
        
        configureFirebase()
        
        self.modelContext = modelContext
        
        self.fcfModule = FCFModuleImpl()
        self.firestoreModule = FirestoreModuleImpl()
        self.fcmModule = FCMModuleImpl(
            modelContext: modelContext,
            firestoreRepository: firestoreModule.firestoreRepository
        )
        self.authModule = AuthModuleImpl(
            cloudFunctionsRepository: fcfModule.fcfRepository,
            firebaseAuth: .auth(),
            firestoreRepository: firestoreModule.firestoreRepository,
            fcmRepository: fcmModule.fcmRepository
        )
        self.wordpressModule = WordpressModuleImpl(
            firestoreRepository: firestoreModule.firestoreRepository,
            modelContext: modelContext
        )
        self.storageModule = StorageModuleImpl()
        self.accountModule = AccountModuleImpl(
            anlaesseRepository: wordpressModule.anlaesseRepository,
            firestoreRepository: firestoreModule.firestoreRepository,
            cloudFunctionsRepository: fcfModule.fcfRepository,
            fcmService: fcmModule.fcmService,
            storageRepository: storageModule.storageRepository
        )
        self.appState = AppStateViewModel(
            authService: authModule.authService,
            leiterbereichService: accountModule.leiterbereichService,
            schoepflialarmService: accountModule.schoepflialarmService,
            wordpressApi: wordpressModule.wordpressApi
        )
        self.notificationHandler = NotificationHandler(
            appState: appState,
            authService: authModule.authService,
            schoepflialarmService: accountModule.schoepflialarmService,
            fcmService: fcmModule.fcmService
        )
    }
    
    
}

private func configureFirebase() {
    
    FirebaseConfiguration.shared.setLoggerLevel(.debug)
    AppCheck.setAppCheckProviderFactory(SeesturmAppCheckProviderFactory())
    FirebaseApp.configure()
}
