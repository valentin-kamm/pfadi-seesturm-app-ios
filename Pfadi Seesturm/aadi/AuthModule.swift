//
//  AuthModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI
import FirebaseFunctions
import FirebaseAuth

protocol AuthModule {
    
    var appAuthApi: AuthApi { get }
    
    var firebaseAuth: FirebaseAuth.Auth { get }
    
    var cloudFunctionsRepository: CloudFunctionsRepository { get }
    
    var firestoreRepository: FirestoreRepository { get }
    
    var authRepository: AuthRepository { get }
    var authService: AuthService { get }
}

class AuthModuleImpl: AuthModule {
    
    let cloudFunctionsRepository: CloudFunctionsRepository
    let firebaseAuth: FirebaseAuth.Auth
    let firestoreRepository: FirestoreRepository
    init(
        cloudFunctionsRepository: CloudFunctionsRepository,
        firebaseAuth: FirebaseAuth.Auth,
        firestoreRepository: FirestoreRepository
    ) {
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.firebaseAuth = firebaseAuth
        self.firestoreRepository = firestoreRepository
    }
        
    lazy var appAuthApi: AuthApi = AuthApiImpl(
        appConfig: Constants.OAUTH_CONFIG,
        firebaseAuth: firebaseAuth
    )
    
    lazy var authRepository: AuthRepository = AuthRepositoryImpl(authApi: appAuthApi)
    lazy var authService: AuthService = AuthService(
        authRepository: authRepository,
        cloudFunctionsRepository: cloudFunctionsRepository,
        firestoreRepository: firestoreRepository
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
        firestoreRepository: FirestoreRepositoryImpl(db: .firestore(), api: FirestoreApiImpl(db: .firestore()))
    )
}
extension EnvironmentValues {
    var authModule: AuthModule {
        get { self[AuthModuleKey.self] }
        set { self[AuthModuleKey.self] = newValue }
    }
}
