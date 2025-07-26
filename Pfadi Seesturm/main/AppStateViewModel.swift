//
//  AppStateViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.12.2024.
//

import SwiftUI

@MainActor
class AppStateViewModel: ObservableObject {
    
    @Published var authState: SeesturmAuthState = .signedOut(state: .idle)
    @Published var selectedTab: AppMainTab = .home
    @Published var tabNavigationPaths: [AppMainTab: NavigationPath] = [
        .home: NavigationPath(),
        .aktuell: NavigationPath(),
        .anlässe: NavigationPath(),
        .mehr: NavigationPath(),
        .account: NavigationPath()
    ]
    @Published var showAppVersionCheckOverlay: Bool = false
    
    private let authService: AuthService
    private let leiterbereichService: LeiterbereichService
    private let schoepflialarmService: SchoepflialarmService
    private let fcmService: FCMService
    private let wordpressApi: WordpressApi
    
    init(
        authService: AuthService,
        leiterbereichService: LeiterbereichService,
        schoepflialarmService: SchoepflialarmService,
        fcmService: FCMService,
        wordpressApi: WordpressApi
    ) {
        self.authService = authService
        self.leiterbereichService = leiterbereichService
        self.schoepflialarmService = schoepflialarmService
        self.fcmService = fcmService
        self.wordpressApi = wordpressApi
        
        runOnAppStart()
    }
    
    private func runOnAppStart() {
                
        Task {
            async let reauthResult: Void = await reauthenticateOnAppStart()
            async let versionCheckResult: Void = await checkMinimumRequiredAppBuild()
            
            let (_, _) = await (reauthResult, versionCheckResult)
            
            // re-subscribe to schöepflialarm topic in the background after re-auth is complete
            let isHitobitoUser = await authService.isCurrentUserHitobitoUser()
            if isHitobitoUser {
                let _ = await fcmService.subscribe(to: .schoepflialarm)
            }
        }
    }
    
    func path(for tab: AppMainTab) -> Binding<NavigationPath> {
        Binding(
            get: { self.tabNavigationPaths[tab] ?? NavigationPath() },
            set: { self.tabNavigationPaths[tab] = $0 }
        )
    }
    
    func signOutErrorSnackbarBinding(user: FirebaseHitobitoUser) -> Binding<Bool> {
        return Binding(
            get: {
                switch self.authState {
                case .signedInWithHitobito(_, let state):
                    switch state {
                    case .error(_, _):
                        return true
                    default:
                        return false
                    }
                default:
                    return false
                }
            },
            set: { _ in
                self.changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
            }
        )
    }
    
    var signOutErrorSnackbarMessage: String {
        switch self.authState {
        case .signedInWithHitobito(_, let state):
            switch state {
            case .error(_, let message):
                return message
            default:
                return "Ein unbekannter Fehler ist aufgetreten"
            }
        default:
            return "Ein unbekannter Fehler ist aufgetreten."
        }
    }
    
    private func reauthenticateOnAppStart() async {
        
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.reauthenticateOnAppStart()
        
        switch result {
        case .success(let user):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
        case .error(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func authenticate() async {
        
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.authenticate()
        
        switch result {
        case .success(let user):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
        case .error(let error):
            switch error {
            case .cancelled:
                changeAuthState(newAuthState: .signedOut(state: .idle))
            default:
                changeAuthState(newAuthState: .signedOut(state: .error(action: (), message: error.defaultMessage)))
            }
        }
    }
    
    func signOut(user: FirebaseHitobitoUser) async {
        
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        let result = await authService.signOut(user: user)
        
        switch result {
        case .error(let e):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func deleteAccount(user: FirebaseHitobitoUser) async {
        
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        let result = await authService.deleteAccount(user: user)
        
        switch result {
        case .error(let e):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func navigate(from url: URL) {
        if let universalLink = SeesturmUniversalLink(url: url) {
            if case .oauthCallback = universalLink {
                authService.resumeExternalUserAgentFlow(url: url)
            }
            let tab = universalLink.navigationDestination.0
            let path = universalLink.navigationDestination.1
            setNavigationPath(tab: tab, path: path)
            changeTab(newTab: tab)
        }
    }
    
    func changeTab(newTab: AppMainTab) {
        withAnimation {
            selectedTab = newTab
        }
    }
    func setNavigationPath(tab: AppMainTab, path: NavigationPath) {
        withAnimation {
            tabNavigationPaths[tab] = path
        }
    }
    func appendToNavigationPath(tab: AppMainTab, destination: any Hashable) {
        withAnimation {
            tabNavigationPaths[tab]?.append(destination)
        }
    }
    
    // function to change auth state
    private func changeAuthState(newAuthState: SeesturmAuthState) {
        withAnimation {
            authState = newAuthState
        }
    }
    func resetAuthState() {
        changeAuthState(newAuthState: .signedOut(state: .idle))
    }
    
    private func checkMinimumRequiredAppBuild() async {
        
        let minimimRequiredBuildResult = try? await wordpressApi.getMinimumRequiredAppBuild()
        let currentBuildResult = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String).flatMap(Int.init)
        
        if let minRequiredBuild = minimimRequiredBuildResult, let currentBuild = currentBuildResult, currentBuild < minRequiredBuild.ios {
            withAnimation {
                showAppVersionCheckOverlay = true
            }
        }
    }
}
