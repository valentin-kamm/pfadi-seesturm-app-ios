//
//  AuthModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI
import FirebaseFunctions
import FirebaseAuth
import SwiftData

protocol AuthModule {
    
    var authApi: AuthApi { get }
    var authRepository: AuthRepository { get }
    var authService: AuthService { get }
}

class AuthModuleImpl: AuthModule {
    
    private let firebaseAuth: FirebaseAuth.Auth
    private let cloudFunctionsRepository: CloudFunctionsRepository
    private let firestoreRepository: FirestoreRepository
    private let fcmRepository: FCMRepository
    
    init(
        cloudFunctionsRepository: CloudFunctionsRepository,
        firebaseAuth: FirebaseAuth.Auth,
        firestoreRepository: FirestoreRepository,
        fcmRepository: FCMRepository
    ) {
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.firebaseAuth = firebaseAuth
        self.firestoreRepository = firestoreRepository
        self.fcmRepository = fcmRepository
    }
        
    lazy var authApi: AuthApi = AuthApiImpl(
        appConfig: Constants.OAUTH_CONFIG,
        firebaseAuth: firebaseAuth
    )
    
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(authApi: authApi)
    
    lazy var authService: AuthService = AuthService(
        authRepository: authRepository,
        cloudFunctionsRepository: cloudFunctionsRepository,
        firestoreRepository: firestoreRepository,
        fcmRepository: fcmRepository
    )
}

struct AuthModuleKey: EnvironmentKey {
    static let defaultValue: AuthModule = AuthModuleImpl(
        cloudFunctionsRepository: CloudFunctionsRepositoryImpl(
            api: CloudFunctionsApiImpl(
                functions: Functions.functions()
            )
        ),
        firebaseAuth: .auth(),
        firestoreRepository: FirestoreRepositoryImpl(
            db: .firestore(),
            api: FirestoreApiImpl(db: .firestore())),
        fcmRepository: FCMRepositoryImpl(
            api: FCMApiImpl(
                messaging: .messaging()
            ),
            modelContext: ModelContext(seesturmModelContainer)
        )
    )
}
extension EnvironmentValues {
    var authModule: AuthModule {
        get { self[AuthModuleKey.self] }
        set { self[AuthModuleKey.self] = newValue }
    }
}
