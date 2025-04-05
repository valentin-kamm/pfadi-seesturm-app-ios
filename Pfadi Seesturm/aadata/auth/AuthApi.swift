//
//  AppAuthApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import AppAuth
import FirebaseAuth
import AuthenticationServices

protocol AuthApi {
    
    var userAgentSession: OIDExternalUserAgentSession? { get }
    
    var firebaseAuth: FirebaseAuth.Auth { get }
    
    func resumeExternalUserAgentFlow(url: URL)
    
    func fetchIssuerMetadata() async throws -> OIDServiceConfiguration
    
    func performAuthorizationRedirect(
        config: OIDServiceConfiguration,
        viewController: UIViewController
    ) async throws -> OIDAuthorizationResponse
    
    func redeemCodeForTokens(
        authResponse: OIDAuthorizationResponse
    ) async throws -> OIDTokenResponse
    
    func getHitobitoAccessToken(
        tokenResponse: OIDTokenResponse
    ) throws -> String
    
    func readHitobitoUserInfo(
        accessToken: String
    ) async throws -> HitobitoUserInfoDto
    
    func authenticateWithFirebase(firebaseToken: String) async throws
    
    func signOutFromFirebase() throws
    
    func deleteFirebaseAccount() async throws
    
    func getCurrentUid() -> String?
}

class AuthApiImpl: AuthApi {
    
    let appConfig: OAuthApplicationConfig
    let firebaseAuth: FirebaseAuth.Auth
    init(appConfig: OAuthApplicationConfig, firebaseAuth: FirebaseAuth.Auth) {
        self.appConfig = appConfig
        self.firebaseAuth = firebaseAuth
        /*
        #if DEBUG
        firebaseAuth.useEmulator(withHost: "127.0.0.1", port: 9099)
        #endif
         */
    }
    
    var userAgentSession: OIDExternalUserAgentSession?
    
    func resumeExternalUserAgentFlow(url: URL) {
        if let session = userAgentSession {
            session.resumeExternalUserAgentFlow(with: url)
            userAgentSession = nil
        }
    }
    
    func readHitobitoUserInfo(accessToken: String) async throws -> HitobitoUserInfoDto {
        return try await HttpUtil.shared.performGetRequest(
            urlString: Constants.OAUTH_USER_INFO_ENDPOINT,
            keyDecodingStrategy: .convertFromSnakeCase,
            headers: [HttpHeader(value: "Bearer \(accessToken)", key: "Authorization")]
        )
    }
    
    func getHitobitoAccessToken(tokenResponse: OIDTokenResponse) throws -> String {
        guard let accessToken = tokenResponse.accessToken, !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PfadiSeesturmError.authError(message: "Access Token ist leer.")
        }
        return accessToken
    }
    
    func redeemCodeForTokens(authResponse: OIDAuthorizationResponse) async throws -> OIDTokenResponse {
        
        let extraParams = [String: String]()
        guard let request = authResponse.tokenExchangeRequest(withAdditionalParameters: extraParams) else {
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
        
        let extraParams: [String: String] = [:]
        let request = OIDAuthorizationRequest(
            configuration: config,
            clientId: appConfig.clientID,
            clientSecret: nil,
            scopes: appConfig.scope,
            redirectURL: appConfig.redirectUri,
            responseType: OIDResponseTypeCode,
            additionalParameters: extraParams
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            self.userAgentSession = OIDAuthorizationService.present(
                request,
                presenting: viewController,
                prefersEphemeralSession: true) { authResponse, error in
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
    
    func fetchIssuerMetadata() async throws -> OIDServiceConfiguration {
        let config = try await OIDAuthorizationService.discoverConfiguration(forIssuer: appConfig.issuer)
        return config.setCustomTokenEndpoint(customTokenEndpoint: Constants.OAUTH_TOKEN_ENDPOINT)
    }
    
    func authenticateWithFirebase(firebaseToken: String) async throws {
        try await firebaseAuth.signIn(withCustomToken: firebaseToken)
    }
    
    func signOutFromFirebase() throws {
        try firebaseAuth.signOut()
    }
    
    func deleteFirebaseAccount() async throws {
        try await firebaseAuth.currentUser?.delete()
    }
    
    func getCurrentUid() -> String? {
        return firebaseAuth.currentUser?.uid
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
