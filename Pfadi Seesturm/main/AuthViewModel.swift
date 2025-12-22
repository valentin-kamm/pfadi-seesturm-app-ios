//
//  AuthViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var authState: SeesturmAuthState = .signedOut(state: .idle)
    
    private let authService: AuthService
    private let profilePictureService: ProfilePictureService
    
    init(
        authService: AuthService,
        profilePictureService: ProfilePictureService
    ) {
        self.authService = authService
        self.profilePictureService = profilePictureService
        
        Task {
            await reauthenticateWithHitobito()
        }
    }
    
    func authenticateWithHitobito() async {
        
        updateAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.authenticate()
        
        switch result {
        case .success(let user):
            updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
        case .error(let error):
            switch error {
            case .cancelled:
                updateAuthState(newAuthState: .signedOut(state: .idle))
            default:
                updateAuthState(newAuthState: .signedOut(state: .error(action: (), message: error.defaultMessage)))
            }
        }
    }
    
    private func reauthenticateWithHitobito() async {
        
        updateAuthState(newAuthState: .signedOut(state: .loading(action: ())))
        let result = await authService.reauthenticateWithHitobito(resubscribeToSchoepflialarm: true)
        
        switch result {
        case .success(let user):
            updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
        case .error(_):
            updateAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func signOut(user: FirebaseHitobitoUser) async {
        
        updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        let result = await authService.signOut(user: user)
        
        switch result {
        case .error(let e):
            updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            updateAuthState(newAuthState: .signedOut(state: .idle))
        }
    }
    
    func deleteAccount(user: FirebaseHitobitoUser) async {
        
        updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .loading(action: ())))
        let result = await authService.deleteAccount(user: user)
        
        switch result {
        case .error(let e):
            updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .error(action: (), message: e.defaultMessage)))
        case .success(_):
            updateAuthState(newAuthState: .signedOut(state: .idle))
        }
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
                self.updateAuthState(newAuthState: .signedInWithHitobito(user: user, state: .idle))
            }
        )
    }
    
    func setProfilePicture(picture: ProfilePictureData) async -> SeesturmResult<Void, StorageError> {
        
        guard case .signedInWithHitobito(let user, _) = authState
        else {
            return .error(.unauthenticated(message: "Du bist nicht angemeldet und kannst somit keine Profilbild hochladen."))
        }

        let result = await profilePictureService.uploadProfilePicture(user: user, picture: picture)
        
        switch result {
        case .error(let e):
            return .error(e)
        case .success(let url):
            updateLocalProfilePictureUrl(url: url)
            return .success(())
        }
        
    }
    
    func deleteProfilePicture() async -> SeesturmResult<Void, StorageError> {
        
        guard case .signedInWithHitobito(let user, let state) = authState else {
            return .error(.unauthenticated(message: "Du bist nicht angemeldet und kannst dein Profilbild somit nicht löschen."))
        }
        
        let result = await profilePictureService.deleteProfilePicture(user: user)
        
        switch result {
        case .error(let e):
            return .error(e)
        case .success(let d):
            updateLocalProfilePictureUrl(url: nil)
            return .success(())
        }

    }
    
    private func updateLocalProfilePictureUrl(url: URL?) {
        
        guard case .signedInWithHitobito(let user, let state) = authState else {
            return
        }
        let newUser = FirebaseHitobitoUser(user, newProfilePictureUrl: url)
        updateAuthState(newAuthState: .signedInWithHitobito(user: newUser, state: state))
    }
    
    private func updateAuthState(newAuthState: SeesturmAuthState) {
        withAnimation {
            authState = newAuthState
        }
    }
    func resetAuthState() {
        updateAuthState(newAuthState: .signedOut(state: .idle))
    }
    
    func resumeExternalUserAgentFlow(url: URL) {
        authService.resumeExternalUserAgentFlow(url: url)
    }
}
