//
//  AuthService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI
import FirebaseAuth

class AuthService {
    
    private let authRepository: AuthRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    private let firestoreRepository: FirestoreRepository
    private let fcmRepository: FCMRepository
    
    init(
        authRepository: AuthRepository,
        cloudFunctionsRepository: CloudFunctionsRepository,
        firestoreRepository: FirestoreRepository,
        fcmRepository: FCMRepository,
    ) {
        self.authRepository = authRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.firestoreRepository = firestoreRepository
        self.fcmRepository = fcmRepository
    }
    
    func authenticate() async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        do {
            let (userInfo, hitobitoAccessToken) = try await authRepository.getHitobitoUserAndToken()
            let firebaseAuthToken = try await cloudFunctionsRepository.getFirebaseAuthToken(userId: userInfo.sub, hitobitoAccessToken: hitobitoAccessToken)
            let firebaseUser = try await authRepository.authenticateWithFirebase(firebaseToken: firebaseAuthToken)
            let firebaseUserClaims = try await authRepository.getCurrentFirebaseUserClaims(user: firebaseUser)
            let firebaseUserRole = try FirebaseHitobitoUserRole(claims: firebaseUserClaims)
            let firebaseUserDto = userInfo.toFirebaseHitobitoUserDto(role: firebaseUserRole.rawValue)
            try await upsertUser(user: firebaseUserDto, id: userInfo.sub)
            let firebaseHitobitoUserDto: FirebaseHitobitoUserDto = try await firestoreRepository.readDocument(document: .user(id: userInfo.sub))
            let firebaseHitobitoUser = try firebaseHitobitoUserDto.toFirebaseHitobitoUser()
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
    
    func reauthenticateOnAppStart() async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        if let user = authRepository.getCurrentFirebaseUser() {
            do {
                let claims = try await authRepository.getCurrentFirebaseUserClaims(user: user)
                let _ = try FirebaseHitobitoUserRole(claims: claims)
                let firebaseHitobitoUserDto: FirebaseHitobitoUserDto = try await firestoreRepository.readDocument(document: SeesturmFirestoreDocument.user(id: user.uid))
                let firebaseHitobitoUser = try firebaseHitobitoUserDto.toFirebaseHitobitoUser()
                return .success(firebaseHitobitoUser)
            }
            catch let error as PfadiSeesturmError {
                return .error(.signInError(message: "Die Anmeldung ist fehlgeschlagen. Versuche es erneut oder kontaktiere den Admin. \(error.localizedDescription)"))
            }
            catch {
                return .error(.signInError(message: "Bei der Anmeldung ist ein unbekannter Fehler aufgetreten. Versuche es erneut. \(error.localizedDescription)"))
            }
        }
        else {
            return .error(.signInError(message: "Es ist kein Benutzer angemeldet. Neue Anmeldung nötig."))
        }
    }
    
    private func upsertUser(user: FirebaseHitobitoUserDto, id: String) async throws {
        do {
            try await firestoreRepository.upsertDocument(object: user, document: SeesturmFirestoreDocument.user(id: id))
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
