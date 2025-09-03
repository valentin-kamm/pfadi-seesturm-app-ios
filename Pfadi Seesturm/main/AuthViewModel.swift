//
//  AuthViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.08.2025.
//

import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var authState: SeesturmAuthState = .signedOut(state: .idle)
    
    private var userListeningTask: Task<(), Never>? = nil
    
    private let authService: AuthService
    
    init(
        authService: AuthService
    ) {
        self.authService = authService
        
        Task {
            await reauthenticateOnAppStart()
        }
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
    
    func authenticate() async {
        
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.authenticate()
        
        switch result {
        case .success(let user):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
            startListeningToUser(userId: user.userId)
        case .error(let error):
            switch error {
            case .cancelled:
                changeAuthState(newAuthState: .signedOut(state: .idle))
            default:
                changeAuthState(newAuthState: .signedOut(state: .error(action: (), message: error.defaultMessage)))
            }
        }
    }
    
    private func reauthenticateOnAppStart() async {
        
        changeAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.reauthenticate(resubscribeToSchoepflialarm: true)
        
        switch result {
        case .success(let user):
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
            startListeningToUser(userId: user.userId)
        case .error(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func signOut(user: FirebaseHitobitoUser) async {
        
        stopListeningToUser()
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        
        let result = await authService.signOut(user: user)
        
        switch result {
        case .error(let e):
            startListeningToUser(userId: user.userId)
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func deleteAccount(user: FirebaseHitobitoUser) async {
        
        stopListeningToUser()
        changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        
        let result = await authService.deleteAccount(user: user)
        
        switch result {
        case .error(let e):
            startListeningToUser(userId: user.userId)
            changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            changeAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    private func startListeningToUser(userId: String) {
        
        stopListeningToUser()
        
        userListeningTask = Task {
            for await userResult in authService.listenToUser(userId: userId) {
                switch userResult {
                case .error(_):
                    changeAuthState(newAuthState: .signedOut(state: .error(action: (), message: "Der Benutzer konnte nicht von der Datenbank gelesen werden.")))
                case .success(let user):
                    changeAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
                }
            }
        }
    }
    
    private func stopListeningToUser() {
        userListeningTask?.cancel()
        userListeningTask = nil
    }
    
    func resetAuthState() {
        stopListeningToUser()
        changeAuthState(newAuthState: .signedOut(state: .idle))
    }
    
    private func changeAuthState(newAuthState: SeesturmAuthState) {
        withAnimation {
            authState = newAuthState
        }
    }
}
