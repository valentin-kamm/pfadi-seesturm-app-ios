//
//  AccountModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI

protocol AccountModule {
    
    var leiterbereichService: LeiterbereichService { get }
    var stufenbereichService: StufenbereichService { get }
}

class AccountModuleImpl: AccountModule {
    
    private let termineRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    init(
        termineRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository,
        cloudFunctionsRepository: CloudFunctionsRepository
    ) {
        self.termineRepository = termineRepository
        self.firestoreRepository = firestoreRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
    }
    
    lazy var leiterbereichService: LeiterbereichService = LeiterbereichService(
        termineRepository: termineRepository,
        firestoreRepository: firestoreRepository
    )
    lazy var stufenbereichService: StufenbereichService = StufenbereichService(
        termineRepository: termineRepository,
        firestoreRepository: firestoreRepository,
        cloudFunctionsRepository: cloudFunctionsRepository
    )
        
}

struct AccountModuleKey: EnvironmentKey {
    static let defaultValue: AccountModule = AccountModuleImpl(
        termineRepository: AnlaesseRepositoryImpl(
            api: WordpressApiImpl(
                baseUrl: Constants.SEESTURM_API_BASE_URL
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
        )
    )
}
extension EnvironmentValues {
    var accountModule: AccountModule {
        get { self[AccountModuleKey.self] }
        set { self[AccountModuleKey.self] = newValue }
    }
}
