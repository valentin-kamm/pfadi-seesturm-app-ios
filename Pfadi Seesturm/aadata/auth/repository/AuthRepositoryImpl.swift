//
//  AuthRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import SwiftUI

class AuthRepositoryImpl: AuthRepository {
      
    let authApi: AuthApi
    init(authApi: AuthApi) {
        self.authApi = authApi
    }
    
    func getHitobitoUserAndToken() async throws -> (HitobitoUserInfoDto, String) {
        
        let viewController = try await getViewController()
        let issuerConfig = try await authApi.fetchIssuerMetadata()
        let authResponse = try await authApi.performAuthorizationRedirect(
            config: issuerConfig,
            viewController: viewController
        )
        let tokenResponse = try await authApi.redeemCodeForTokens(authResponse: authResponse)
        let accessToken = try authApi.getHitobitoAccessToken(tokenResponse: tokenResponse)
        let userInfo = try await authApi.readHitobitoUserInfo(accessToken: accessToken)
        return (userInfo, accessToken)
    }
    
    @MainActor
    private func getViewController() throws -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        guard let keyWindow = scene.windows.first(where: \.isKeyWindow) else {
            throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        guard let rootViewController = keyWindow.rootViewController else {
            throw PfadiSeesturmAppError.authError(message: "Anmeldeprozess konnte nicht gestartet werden.")
        }
        return rootViewController
    }
    
    func resumeExternalUserAgentFlow(url: URL) {
        authApi.resumeExternalUserAgentFlow(url: url)
    }
    
    func authenticateWithFirebase(firebaseToken: String) async throws {
        try await authApi.authenticateWithFirebase(firebaseToken: firebaseToken)
    }
    
    func validatePermission(userInfo: HitobitoUserInfoDto) throws {
        
        if let groupIdArray = userInfo.roles {
            let roles = groupIdArray.map { $0?.groupId }
            if !roles.contains(Constants.HITOBITO_APP_GROUP_ID) {
                throw PfadiSeesturmError.authError(message: "Du hast keine Berechtigung, um dich bei der Pfadi Seesturm App anzumelden. Wende dich an die MiData-Addressverwalter der Pfadi Seesturm.")
            }
        }
        else {
            throw PfadiSeesturmError.authError(message: "Du hast keine Berechtigung, um dich bei der Pfadi Seesturm App anzumelden. Wende dich an die MiData-Addressverwalter der Pfadi Seesturm.")
        }
    }
    
    func signOutFromFirebase() throws {
        try authApi.signOutFromFirebase()
    }
    
    func deleteAccount(user: FirebaseHitobitoUser) async throws {
        try await authApi.deleteFirebaseAccount()
    }
    
    func getCurrentUid() -> String? {
        return authApi.getCurrentUid()
    }
}
