//
//  AccountModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI
import SwiftData
import FirebaseStorage

protocol AccountModule {
    
    var leiterbereichService: LeiterbereichService { get }
    var stufenbereichService: StufenbereichService { get }
    var schoepflialarmService: SchoepflialarmService { get }
}

class AccountModuleImpl: AccountModule {
    
    private let anlaesseRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    private let fcmService: FCMService
    private let storageRepository: StorageRepository
    
    init(
        anlaesseRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository,
        cloudFunctionsRepository: CloudFunctionsRepository,
        fcmService: FCMService,
        storageRepository: StorageRepository
    ) {
        self.anlaesseRepository = anlaesseRepository
        self.firestoreRepository = firestoreRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.fcmService = fcmService
        self.storageRepository = storageRepository
    }
    
    lazy var leiterbereichService: LeiterbereichService = LeiterbereichService(
        termineRepository: anlaesseRepository,
        firestoreRepository: firestoreRepository,
        storageRepository: storageRepository
    )
    lazy var stufenbereichService: StufenbereichService = StufenbereichService(
        termineRepository: anlaesseRepository,
        firestoreRepository: firestoreRepository,
        cloudFunctionsRepository: cloudFunctionsRepository
    )
    lazy var schoepflialarmService: SchoepflialarmService = SchoepflialarmService(
        firestoreRepository: firestoreRepository,
        fcmService: fcmService,
        fcfRepository: cloudFunctionsRepository
    )
}

struct AccountModuleKey: EnvironmentKey {
    
    static let defaultValue: AccountModule = AccountModuleImpl(
        anlaesseRepository: AnlaesseRepositoryImpl(
            api: WordpressApiImpl(
                baseUrl: Constants.WORDPRESS_API_BASE_URL
            )
        ),
        firestoreRepository: FirestoreRepositoryImpl(
            db: .firestore(),
            api: FirestoreApiImpl(db: .firestore())
        ),
        cloudFunctionsRepository: CloudFunctionsRepositoryImpl(
            api: CloudFunctionsApiImpl(
                functions: .functions()
            )
        ),
        fcmService: FCMService(
            repository: FCMRepositoryImpl(
                api: FCMApiImpl(messaging: .messaging()),
                modelContext: ModelContext(seesturmModelContainer)
            ),
            firestoreRepository: FirestoreRepositoryImpl(
                db: .firestore(),
                api: FirestoreApiImpl(
                    db: .firestore()
                )
            ),
            notificationCenter: UNUserNotificationCenter.current()
        ),
        storageRepository: StorageRepositoryImpl(
            api: StorageApiImpl(),
            storage: Storage.storage()
        )
    )
}
extension EnvironmentValues {
    var accountModule: AccountModule {
        get { self[AccountModuleKey.self] }
        set { self[AccountModuleKey.self] = newValue }
    }
}
