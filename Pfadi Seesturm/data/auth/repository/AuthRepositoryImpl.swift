//
//  AuthRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import UIKit
import FirebaseAuth

class AuthRepositoryImpl: AuthRepository {
    
    private let authApi: AuthApi
    
    init(authApi: AuthApi) {
        self.authApi = authApi
    }
    
    func getHitobitoUserAndToken() async throws -> (HitobitoUserInfoDto, HitobitoAccessToken) {
        
        let viewController = try await getViewController()
        let issuerConfig = try await authApi.fetchIssuerConfiguration()
        let authResponse = try await authApi.performAuthorizationRedirect(
            config: issuerConfig,
            viewController: viewController
        )
        let tokenResponse = try await authApi.redeemCodeForTokens(authResponse: authResponse)
        let accessToken = try authApi.getHitobitoAccessToken(tokenResponse: tokenResponse)
        let userInfo = try await authApi.readHitobitoUserInfo(accessToken: accessToken)
        try validatePermission(userInfo: userInfo)
        return (userInfo, accessToken)
    }
    
    @MainActor
    private func getViewController() throws -> UIViewController {
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            throw PfadiSeesturmError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        guard let keyWindow = scene.windows.first(where: \.isKeyWindow) else {
            throw PfadiSeesturmError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        guard let rootViewController = keyWindow.rootViewController else {
            throw PfadiSeesturmError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        return rootViewController
    }
    
    private func validatePermission(userInfo: HitobitoUserInfoDto) throws {
        
        guard let roles = userInfo.roles?.compactMap({ $0?.groupId }),
              roles.contains(Constants.HITOBITO_APP_GROUP_ID) else {
            throw PfadiSeesturmError.authError(message: "Du hast keine Berechtigung, um dich bei der Pfadi Seesturm App anzumelden. Wende dich an die MiData-Addressverwalter der Pfadi Seesturm.")
        }
    }
    
    func resumeExternalUserAgentFlow(url: URL) {
        authApi.resumeExternalUserAgentFlow(url: url)
    }
    
    func authenticateWithFirebase(firebaseToken: FirebaseAuthToken) async throws -> User {
        return try await authApi.authenticateWithFirebase(firebaseToken: firebaseToken)
    }
    
    func signOutFromFirebase() throws {
        try authApi.signOutFromFirebase()
    }
    
    func deleteFirebaseUserAccount() async throws {
        try await authApi.deleteFirebaseUserAccount()
    }
    
    func getCurrentUid() -> String? {
        return authApi.getCurrentUid()
    }
    
    func getCurrentFirebaseUser() -> User? {
        return authApi.getCurrentFirebaseUser()
    }
    
    func getCurrentFirebaseUserClaims(user: User) async throws -> FirebaseUserClaims {
        return try await authApi.getCurrentFirebaseUserClaims(user: user)
    }
}
