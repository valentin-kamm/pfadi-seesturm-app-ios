//
//  AuthRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI

protocol AuthRepository {
    
    func getHitobitoUserAndToken() async throws -> (HitobitoUserInfoDto, String)
    func resumeExternalUserAgentFlow(url: URL)
    func authenticateWithFirebase(firebaseToken: String) async throws
    func validatePermission(userInfo: HitobitoUserInfoDto) throws
    func signOutFromFirebase() throws
    func deleteAccount(user: FirebaseHitobitoUser) async throws
    func getCurrentUid() -> String?
}
