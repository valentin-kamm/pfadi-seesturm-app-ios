//
//  AppDependencies.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.03.2025.
//
import FirebaseMessaging
import FirebaseAppCheck
import FirebaseCore
import FirebaseAuth

@MainActor
final class AppDependencies {
    
    let authModule: AuthModule
    let fcmModule: FCMModule
    let firestoreModule: FirestoreModule
    let wordpressModule: WordpressModule
    let universalLinksHandler: UniversalLinksHandler
    let fcfModule: FCFModule
    let appState: AppStateViewModel
    let accountModule: AccountModule
    
    init() {
        self.fcfModule = FCFModuleImpl()
        self.firestoreModule = FirestoreModuleImpl()
        self.universalLinksHandler = UniversalLinksHandler()
        self.authModule = AuthModuleImpl(
            cloudFunctionsRepository: fcfModule.fcfRepository,
            firebaseAuth: .auth(),
            firestoreRepository: firestoreModule.firestoreRepository
        )
        self.fcmModule = FCMModuleImpl(
            messaging: Messaging.messaging(),
            notificationCenter: UNUserNotificationCenter.current()
        )
        self.wordpressModule = WordpressModuleImpl(firestoreRepository: firestoreModule.firestoreRepository)
        self.accountModule = AccountModuleImpl(
            termineRepository: wordpressModule.anlaesseRepository,
            firestoreRepository: firestoreModule.firestoreRepository,
            cloudFunctionsRepository: fcfModule.fcfRepository
        )
        self.appState = AppStateViewModel(
            authService: authModule.authService,
            leiterbereichService: accountModule.leiterbereichService,
            universalLinksHandler: universalLinksHandler
        )
    }
}
