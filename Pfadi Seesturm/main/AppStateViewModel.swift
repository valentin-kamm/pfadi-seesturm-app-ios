//
//  AppNavigationState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.12.2024.
//

import SwiftUI

class AppStateViewModel: StateManager<AppState> {
    
    private let authService: AuthService
    private let leiterbereichService: LeiterbereichService
    private let universalLinksHandler: UniversalLinksHandler
    
    init(
        authService: AuthService,
        leiterbereichService: LeiterbereichService,
        universalLinksHandler: UniversalLinksHandler
    ) {
        self.authService = authService
        self.leiterbereichService = leiterbereichService
        self.universalLinksHandler = universalLinksHandler
        super.init(initialState: AppState())
        
        Task {
            await reauthenticate()
        }
    }
    
    // binding for changing tabs
    var selectedTabBinding: Binding<AppMainTab> {
        Binding(
            get: { self.state.selectedTab },
            set: { newTab in
                self.changeTab(newTab: newTab)
            }
        )
    }
    var homeNavigationPathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.state.tabNavigationPaths[.home]! },
            set: { newPath in
                self.setNavigationPath(tab: .home, path: newPath)
            }
        )
    }
    var aktuellNavigationPathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.state.tabNavigationPaths[.aktuell]! },
            set: { newPath in
                self.setNavigationPath(tab: .aktuell, path: newPath)
            }
        )
    }
    var anlaesseNavigationPathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.state.tabNavigationPaths[.anlässe]! },
            set: { newPath in
                self.setNavigationPath(tab: .anlässe, path: newPath)
            }
        )
    }
    var mehrNavigationPathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.state.tabNavigationPaths[.mehr]! },
            set: { newPath in
                self.setNavigationPath(tab: .mehr, path: newPath)
            }
        )
    }
    var accountNavigationPathBinding: Binding<NavigationPath> {
        Binding(
            get: { self.state.tabNavigationPaths[.account]! },
            set: { newPath in
                self.setNavigationPath(tab: .account, path: newPath)
            }
        )
    }
    func authErrorSnackbarBinding(user: FirebaseHitobitoUser, viewModel: LeiterbereichViewModel) -> Binding<Bool> {
        return Binding(
            get: {
                switch self.state.authState {
                case .signedInWithHitobito(_, let state, _):
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
                self.changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle, leiterbereichViewMode: viewModel))
            }
        )
    }
    var authErrorSnackbarMessage: String {
        switch self.state.authState {
        case .signedInWithHitobito(_, let state, _):
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
    var deleteAccountButtonLoading: Bool {
        switch self.state.authState {
        case .signedInWithHitobito(_, let state, _):
            switch state {
            case .loading(_):
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    // reauthenticate when restarting the app
    private func reauthenticate() async {
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.reauthenticate()
        switch result {
        case .success(let user):
            let viewModel = LeiterbereichViewModel(
                service: leiterbereichService,
                calendar: .termineLeitungsteam,
                userId: user.userId
            )
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle, leiterbereichViewMode: viewModel))
        case .error(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    // start auth flow
    func authenticate() async {
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.authenticate()
        switch result {
        case .success(let user):
            let viewModel = LeiterbereichViewModel(
                service: leiterbereichService,
                calendar: .termineLeitungsteam,
                userId: user.userId
            )
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle, leiterbereichViewMode: viewModel))
        case .error(let error):
            switch error {
            case .cancelled:
                changeAuthState(newAuthState: .signedOut(state: .idle))
            default:
                changeAuthState(newAuthState: .signedOut(state: .error(action: (), message: error.defaultMessage)))
            }
        }
    }
    
    func signOut(user: FirebaseHitobitoUser, viewModel: LeiterbereichViewModel) {
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ()), leiterbereichViewMode: viewModel))
        let result = authService.signOut(user: user)
        switch result {
        case .error(let e):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage), leiterbereichViewMode: viewModel))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func deleteAccount(user: FirebaseHitobitoUser, viewModel: LeiterbereichViewModel) async {
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ()), leiterbereichViewMode: viewModel))
        let result = await authService.deleteUser(user: user)
        switch result {
        case .error(let e):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage), leiterbereichViewMode: viewModel))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    // perform navigation from universal link
    func navigate(from url: URL) {
        if url.isOauthCallback {
            authService.resumeExternalUserAgentFlow(url: url)
        }
        if let (tab, path) = universalLinksHandler.getNavigationDestinationFromUniversalLink(url: url) {
            setNavigationPath(tab: tab, path: path)
            changeTab(newTab: tab)
        }
    }
    
    // functions to navigate
    func changeTab(newTab: AppMainTab) {
        updateState { oldState in
            oldState.selectedTab = newTab
        }
    }
    private func setNavigationPath(tab: AppMainTab, path: NavigationPath) {
        updateState { oldState in
            oldState.tabNavigationPaths[tab] = path
        }
    }
    func appendToNavigationPath(tab: AppMainTab, destination: any Hashable) {
        updateState { oldState in
            oldState.tabNavigationPaths[tab]?.append(destination)
        }
    }
    
    // function to change auth state
    private func changeAuthState(newAuthState: AuthState) {
        updateState { oldState in
            oldState.authState = newAuthState
        }
    }
    func resetAuthState() {
        changeAuthState(newAuthState: .signedOut(state: .idle))
    }
}
