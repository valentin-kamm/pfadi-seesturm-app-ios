//
//  AuthRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI
import FirebaseAuth

typealias HitobitoAccessToken = String
typealias FirebaseAuthToken = String

protocol AuthRepository {
    
    func getHitobitoUserAndToken() async throws -> (HitobitoUserInfoDto, HitobitoAccessToken)
    func resumeExternalUserAgentFlow(url: URL)
    func authenticateWithFirebase(firebaseToken: FirebaseAuthToken) async throws -> User
    func signOutFromFirebase() throws
    func deleteFirebaseUserAccount() async throws
    func getCurrentUid() -> String?
    func getCurrentFirebaseUser() -> User?
    func getCurrentFirebaseUserClaims(user: User) async throws -> FirebaseUserClaims
}
