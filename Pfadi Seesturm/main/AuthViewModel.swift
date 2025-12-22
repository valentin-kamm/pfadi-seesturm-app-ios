//
//  AuthViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.08.2025.
//

import SwiftUI
import Observation

@Observable
@MainActor
class AuthViewModel {
    
    var authState: SeesturmAuthState = .signedOut(state: .idle) {
        didSet {
            handleAuthStateChange(from: oldValue, to: authState)
        }
    }
    
    private var userObservationTask: Task<Void, Never>? = nil
    
    private let authService: AuthService
    
    init(
        authService: AuthService
    ) {
        self.authService = authService
        
        Task {
            await checkExistingSession()
        }
    }
    
    func authenticateWithHitobito() async {
        
        withAnimation {
            authState = .signedOut(state: .signingInWithHitobito)
        }
        
        let result = await authService.authenticateWithHitobito()
        
        switch result {
        case .error(let error):
            switch error {
            case .cancelled:
                withAnimation {
                    authState = .signedOut(state: .idle)
                }
            default:
                withAnimation {
                    authState = .signedOut(state: .error(message: error.defaultMessage))
                }
            }
        case .success(let user):
            withAnimation {
                authState = .signedInWithHitobito(user: user, state: .idle)
            }
        }
    }
    
    private func checkExistingSession() async {
        
        withAnimation {
            authState = .signedOut(state: .signingInWithHitobito)
        }
        
        let result = await authService.reauthenticateWithHitobito(resubscribeToSchoepflialarm: true)
        
        switch result {
        case .error(let error):
            withAnimation {
                authState = .signedOut(state: .error(message: error.defaultMessage))
            }
        case .success(let user):
            withAnimation {
                authState = .signedInWithHitobito(user: user, state: .idle)
            }
        }
    }
    
    func signOut() async {
        
        guard case .signedInWithHitobito(let user, let state) = authState, case state = .idle else {
            return
        }
        
        withAnimation {
            authState = .signedInWithHitobito(user: user, state: .signingOut)
        }
        
        let result = await authService.signOut(user: user)
        
        switch result {
        case .error(let error):
            withAnimation {
                authState = .signedInWithHitobito(user: user, state: .error(message: error.defaultMessage))
            }
        case .success(_):
            withAnimation {
                authState = .signedOut(state: .idle)
            }
        }
    }
    
    func deleteAccount() async {
        
        guard case .signedInWithHitobito(let user, let state) = authState, case state = .idle else {
            return
        }

        withAnimation {
            authState = .signedInWithHitobito(user: user, state: .deletingAccount)
        }
        
        let result = await authService.deleteAccount(user: user)
        
        switch result {
        case .error(let error):
            withAnimation {
                authState = .signedInWithHitobito(user: user, state: .error(message: error.defaultMessage))
            }
        case .success(_):
            withAnimation {
                authState = .signedOut(state: .idle)
            }
        }
    }
    
    private func handleAuthStateChange(from oldState: SeesturmAuthState, to newState: SeesturmAuthState) {
        
        // if the state is the same, do nothing
        guard oldState != newState else {
            return
        }
        
        // check if for the new state, I need to observe the user
        if let user = newState.userToObserve {
            startObservingUser(user: user)
        }
        else {
            stopObservingUser()
        }
    }
    
    private func startObservingUser(user: FirebaseHitobitoUser) {
        
        stopObservingUser()
        
        userObservationTask = Task {
            for await userResult in authService.listenToUser(userId: user.userId) {
                
                guard authState.userToObserve != nil else {
                    // silently drop the error because we were not supposed to listen to the user in the first place
                    continue
                }
                
                // at this point, I know that the 
                
                switch userResult {
                case .error(let error):
                    
                    
                    
                    switch authState {
                    case .signedOut(let state):
                        <#code#>
                    case .signedInWithHitobito(let user, let state):
                        <#code#>
                    }
                    
                    switch authState {
                    case .signedInWithHitobito(_, let state):
                        switch state {
                        case .signingOut, .deletingAccount:
                            // silently drop the error because we were not supposed to listen to the user in the first place
                            break
                        case .idle:
                            <#code#>
                        case .error(let message):
                            <#code#>
                        }
                    case .signedOut(_):
                        // silently drop the error because we were not supposed to listen to the user in the first place
                        break
                    }
                case .success(let user):
                    <#code#>
                }
            }
        }
        
        /*
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
         */
    }
    
    private func stopObservingUser() {
        
        userObservationTask?.cancel()
        userObservationTask = nil
    }
    
    /*
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
     */
}
