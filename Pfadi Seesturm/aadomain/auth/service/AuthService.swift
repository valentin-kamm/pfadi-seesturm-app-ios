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
    init(
        authRepository: AuthRepository,
        cloudFunctionsRepository: CloudFunctionsRepository,
        firestoreRepository: FirestoreRepository
    ) {
        self.authRepository = authRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
        self.firestoreRepository = firestoreRepository
    }
    
    func reauthenticate() async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        if let user = Auth.auth().currentUser, user.isHitobitoUser() {
            do {
                let user = try await readUserFromFirestore(id: user.uid)
                return .success(user)
            }
            catch {
                return .error(.signInError(message: "User konnte nicht von Firestore gelesen werden."))
            }
        }
        else {
            return .error(.signInError(message: "Es ist kein Benutzer angemeldet. Neue Anmeldung nötig."))
        }
    }
    
    func authenticate() async -> SeesturmResult<FirebaseHitobitoUser, AuthError> {
        do {
            let (userInfo, accessToken) = try await authRepository.getHitobitoUserAndToken()
            try authRepository.validatePermission(userInfo: userInfo)
            let firebaseAuthToken = try await cloudFunctionsRepository.getFirebaseAuthToken(userId: userInfo.sub, hitobitoAccessToken: accessToken)
            try await authRepository.authenticateWithFirebase(firebaseToken: firebaseAuthToken)
            let userDtoRequest = userInfo.toFirebaseHitobitoUserDto()
            try await upsertUser(user: userDtoRequest, id: userInfo.sub)
            let user = try await readUserFromFirestore(id: userInfo.sub)
            return .success(user)
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
    
    private func readUserFromFirestore(id: String) async throws -> FirebaseHitobitoUser {
        let document = SeesturmFirestoreDocument.user(id: id)
        let userDto: FirebaseHitobitoUserDto = try await firestoreRepository.readDocument(document: document)
        return try userDto.toFirebaseHitobitoUser()
    }
    
    func signOut(user: FirebaseHitobitoUser) -> SeesturmResult<Void, AuthError> {
        do {
            try authRepository.signOutFromFirebase()
            return .success(())
        }
        catch {
            return .error(.signOutError(message: "Benutzer konnte nicht abgemeldet werden. Versuche es erneut."))
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
    
    func deleteUser(user: FirebaseHitobitoUser) async -> SeesturmResult<Void, AuthError> {
        do {
            try await firestoreRepository.deleteDocument(document: SeesturmFirestoreDocument.user(id: user.userId))
            try await authRepository.deleteAccount(user: user)
            return .success(())
        }
        catch {
            return .error(.deleteAccountError(message: "Der Account konnte nicht gelöscht werden. Versuche es später erneut."))
        }
    }
    
    func getCurrentUid() -> String? {
        return authRepository.getCurrentUid()
    }
}

extension User {
    func isHitobitoUser() -> Bool {
        return self.isAnonymous == false && self.providerID == "Firebase"
    }
}
