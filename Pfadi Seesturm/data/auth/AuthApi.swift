//
//  AppAuthApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import AppAuth
import FirebaseAuth
import AuthenticationServices

typealias FirebaseUserClaims = [String: Any]

protocol AuthApi {
        
    func fetchIssuerConfiguration() async throws -> OIDServiceConfiguration
    func performAuthorizationRedirect(
        config: OIDServiceConfiguration,
        viewController: UIViewController
    ) async throws -> OIDAuthorizationResponse
    func resumeExternalUserAgentFlow(url: URL)
    func redeemCodeForTokens(
        authResponse: OIDAuthorizationResponse
    ) async throws -> OIDTokenResponse
    func getHitobitoAccessToken(
        tokenResponse: OIDTokenResponse
    ) throws -> HitobitoAccessToken
    func readHitobitoUserInfo(
        accessToken: HitobitoAccessToken
    ) async throws -> HitobitoUserInfoDto
    
    func authenticateWithFirebase(firebaseToken: String) async throws -> User
    func signOutFromFirebase() throws
    func deleteFirebaseUserAccount() async throws
    func getCurrentUid() -> String?
    func getCurrentFirebaseUser() -> User?
    func getCurrentFirebaseUserClaims(user: User) async throws -> FirebaseUserClaims
}

class AuthApiImpl: AuthApi {
    
    private let appConfig: OAuthApplicationConfig
    private let firebaseAuth: FirebaseAuth.Auth
    
    init(
        appConfig: OAuthApplicationConfig = Constants.OAUTH_CONFIG,
        firebaseAuth: FirebaseAuth.Auth
        
    ) {
        self.appConfig = appConfig
        self.firebaseAuth = firebaseAuth
    }
        
    private var userAgentSession: OIDExternalUserAgentSession?
    
    func resumeExternalUserAgentFlow(url: URL) {
        
        if let session = userAgentSession {
            session.resumeExternalUserAgentFlow(with: url)
            userAgentSession = nil
        }
    }
    
    func readHitobitoUserInfo(accessToken: HitobitoAccessToken) async throws -> HitobitoUserInfoDto {
        
        return try await HttpUtil.shared.performGetRequest(
            urlString: Constants.OAUTH_USER_INFO_ENDPOINT,
            keyDecodingStrategy: .convertFromSnakeCase,
            headers: [HttpHeader(value: "Bearer \(accessToken)", key: "Authorization")]
        )
    }
    
    func getHitobitoAccessToken(tokenResponse: OIDTokenResponse) throws -> HitobitoAccessToken {
        
        guard let accessToken = tokenResponse.accessToken, !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PfadiSeesturmError.authError(message: "Hitobito Access Token ist leer.")
        }
        return accessToken
    }
    
    func redeemCodeForTokens(authResponse: OIDAuthorizationResponse) async throws -> OIDTokenResponse {
        
        guard let request = authResponse.tokenExchangeRequest() else {
            throw PfadiSeesturmError.authError(message: "Authorization Code konnte nicht gegen Token eingetauscht werden.")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            OIDAuthorizationService.perform(
                request,
                originalAuthorizationResponse: authResponse
            ) { tokenResponse, error in
                if let error = error {
                    continuation.resume(throwing: PfadiSeesturmError.authError(message: "Code kann nicht gegen Token eingetauscht werden: \(error.localizedDescription)"))
                }
                else if let response = tokenResponse {
                    continuation.resume(returning: response)
                }
                else {
                    continuation.resume(throwing: PfadiSeesturmError.authError(message: "Der Access Token ist leer oder ungültig."))
                }
            }
        }
    }
    
    @MainActor
    func performAuthorizationRedirect(
        config: OIDServiceConfiguration,
        viewController: UIViewController
    ) async throws -> OIDAuthorizationResponse {
        
        let extraParams: [String: String] = ["prompt": "login"]
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: appConfig.clientID,
            scopes: appConfig.scope,
            redirectURL: appConfig.redirectUri,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            self.userAgentSession = OIDAuthorizationService.present(
                request,
                presenting: viewController,
                prefersEphemeralSession: true
            ) { authResponse, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == OIDGeneralErrorDomain && nsError.code == OIDErrorCode.userCanceledAuthorizationFlow.rawValue {
                        continuation.resume(throwing: PfadiSeesturmError.cancelled(message: "Anmeldeprozess durch Benutzer abgebrochen."))
                    }
                    else {
                        continuation.resume(throwing: PfadiSeesturmError.authError(message: "Anmeldeprozess wurde unterbrochen: \(error.localizedDescription)"))
                    }
                }
                else if let response = authResponse {
                    continuation.resume(returning: response)
                }
                else {
                    continuation.resume(throwing: PfadiSeesturmError.authError(message: "Der Authorization Code is leer oder ungültig."))
                }
            }
        }
    }
    
    func fetchIssuerConfiguration() async throws -> OIDServiceConfiguration {
        
        let config = try await OIDAuthorizationService.discoverConfiguration(forIssuer: appConfig.issuer)
        return config.setCustomTokenEndpoint(customTokenEndpoint: Constants.OAUTH_TOKEN_ENDPOINT)
    }
    
    func authenticateWithFirebase(firebaseToken: FirebaseAuthToken) async throws -> User {
        return try await firebaseAuth.signIn(withCustomToken: firebaseToken).user
    }
    
    func signOutFromFirebase() throws {
        try firebaseAuth.signOut()
    }
    
    func deleteFirebaseUserAccount() async throws {
        try await firebaseAuth.currentUser?.delete()
    }
    
    func getCurrentUid() -> String? {
        return firebaseAuth.currentUser?.uid
    }
    
    func getCurrentFirebaseUser() -> User? {
        return firebaseAuth.currentUser
    }
    
    func getCurrentFirebaseUserClaims(user: User) async throws -> FirebaseUserClaims {
        let authTokenResult = try await user.getIDTokenResult()
        return authTokenResult.claims
    }
}

extension OIDServiceConfiguration {
    func setCustomTokenEndpoint(customTokenEndpoint: URL) -> OIDServiceConfiguration {
        return OIDServiceConfiguration(
            authorizationEndpoint: authorizationEndpoint,
            tokenEndpoint: customTokenEndpoint,
            issuer: issuer,
            registrationEndpoint: registrationEndpoint,
            endSessionEndpoint: endSessionEndpoint
        )
    }
}
