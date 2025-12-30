//
//  AuthService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthService {
    
    private let authRepository: AuthRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    private let firestoreRepository: FirestoreRepository
    private let fcmRepository: FCMRepository
    private let storageRepository: StorageRepository
    
    init(
        authRepository: AuthRepository,
        cloudFunctionsRepository: CloudFunctionsRepository,
        firestoreRepository: FirestoreRepository,
        fcmRepository: FCMRepository,
        storageRepository: StorageRepository
    ) {
        self.authRepository = authRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.firestoreRepository = firestoreRepository
        self.fcmRepository = fcmRepository
        self.storageRepository = storageRepository
    }
    
    func authenticate() async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        do {
            let (userInfo, hitobitoAccessToken) = try await authRepository.getHitobitoUserAndToken()
            let firebaseAuthToken = try await cloudFunctionsRepository.getFirebaseAuthToken(userId: userInfo.sub, hitobitoAccessToken: hitobitoAccessToken)
            let firebaseUser = try await authRepository.authenticateWithFirebase(firebaseToken: firebaseAuthToken)
            let firebaseUserClaims = try await authRepository.getCurrentFirebaseUserClaims(user: firebaseUser)
            let firebaseUserRole = try FirebaseHitobitoUserRole(claims: firebaseUserClaims)
            let firebaseUserInfoDto = FirebaseHitobitoUserInfoDto(userInfo, role: firebaseUserRole.rawValue)
            try await upsertUser(user: firebaseUserInfoDto, userId: userInfo.sub)
            let firebaseHitobitoUserDto: FirebaseHitobitoUserDto = try await firestoreRepository.readDocument(document: .user(id: userInfo.sub))
            let firebaseHitobitoUser = try FirebaseHitobitoUser(firebaseHitobitoUserDto)
            try await fcmRepository.subscribeToTopic(topic: .schoepflialarm)
            return .success(firebaseHitobitoUser)
        }
        catch let error as PfadiSeesturmError {
            switch error {
            case .cancelled:
                return .error(.cancelled)
            default:
                return .error(.signInError(message: error.localizedDescription))
            }
        }
        catch {
            return .error(.signInError(message: "Unbekannter Fehler: \(error.localizedDescription)"))
        }
    }
    
    func resumeExternalUserAgentFlow(url: URL) {
        authRepository.resumeExternalUserAgentFlow(url: url)
    }
    
    func reauthenticateWithHitobito(resubscribeToSchoepflialarm: Bool) async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        
        guard let firebaseUser = authRepository.getCurrentFirebaseUser() else {
            return .error(.signInError(message: "Es ist kein Benutzer angemeldet. Neue Anmeldung nötig."))
        }
        
        do {
            let claims = try await authRepository.getCurrentFirebaseUserClaims(user: firebaseUser)
            let _ = try FirebaseHitobitoUserRole(claims: claims)
            
            // re-subscribe to schöpflialarm topic, but do not suspend and without caring about the error
            if resubscribeToSchoepflialarm {
                Task {
                    try? await fcmRepository.subscribeToTopic(topic: .schoepflialarm)
                }
            }
            
            let firebaseHitobitoUserDto: FirebaseHitobitoUserDto = try await firestoreRepository.readDocument(document: .user(id: firebaseUser.uid))
            let firebaseHitobitoUser = try FirebaseHitobitoUser(firebaseHitobitoUserDto)
            
            return .success(firebaseHitobitoUser)
        }
        catch {
            let message: String
            if let pfadiSeesturmError = error as? PfadiSeesturmError {
                message = "Die Anmeldung ist fehlgeschlagen. Versuche es erneut oder kontaktiere den Admin. \(pfadiSeesturmError.localizedDescription)"
            }
            else {
                message = "Bei der Anmeldung ist ein unbekannter Fehler aufgetreten. Versuche es erneut. \(error.localizedDescription)"
            }
            return .error(.signInError(message: message))
        }
    }
    
    private func upsertUser(user: FirebaseHitobitoUserInfoDto, userId: String) async throws {
        do {
            try await firestoreRepository.upsertDocument(
                object: user,
                document: .user(id: userId)
            )
        }
        catch {
            throw PfadiSeesturmError.authError(message: "Der Benutzer konnte nicht in der Datenbank gespeichert werden")
        }
    }
    
    func signOut(user: FirebaseHitobitoUser) async -> SeesturmResult<Void, AuthError> {
        do {
            try await fcmRepository.unsubscribeFromTopic(topic: .schoepflialarm)
            try await fcmRepository.unsubscribeFromTopic(topic: .schoepflialarmReaction)
            try authRepository.signOutFromFirebase()
            return .success(())
        }
        catch {
            return .error(.signOutError(message: "Benutzer konnte nicht abgemeldet werden. Versuche es erneut."))
        }
    }
    
    func deleteAccount(user: FirebaseHitobitoUser) async -> SeesturmResult<Void, AuthError> {
        do {
            try await fcmRepository.unsubscribeFromTopic(topic: .schoepflialarm)
            try await fcmRepository.unsubscribeFromTopic(topic: .schoepflialarmReaction)
            try await storageRepository.deleteData(item: .profilePicture(user: user))
            try await firestoreRepository.deleteDocument(document: SeesturmFirestoreDocument.user(id: user.userId))
            try await authRepository.deleteFirebaseUserAccount()
            return .success(())
        }
        catch {
            return .error(.deleteAccountError(message: "Der Account konnte nicht gelöscht werden. Versuche es später erneut."))
        }
    }
    
    func isCurrentUserHitobitoUser() async -> Bool {
        
        guard let currentUser = authRepository.getCurrentFirebaseUser() else {
            return false
        }
        
        do {
            let claims = try await authRepository.getCurrentFirebaseUserClaims(user: currentUser)
            let _ = try FirebaseHitobitoUserRole(claims: claims)
            return true
        }
        catch {
            return false
        }
    }
    
    func getCurrentUid() -> String? {
        return authRepository.getCurrentUid()
    }
}
