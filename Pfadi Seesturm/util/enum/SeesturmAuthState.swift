//
//  SeesturmAuthState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import Foundation

enum SeesturmAuthState {
    
    case signedOut(state: ActionState<Void>)
    case signedInWithHitobito(user: FirebaseHitobitoUser, state: ActionState<Void>)
}

extension SeesturmAuthState {
    
    var showInfoSnackbar: Bool {
        switch self {
        case .signedOut(let state):
            switch state {
            case .idle:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    var signInButtonIsLoading: Bool {
        switch self {
        case .signedOut(let state):
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
    
    var signOutButtonIsLoading: Bool {
        switch self {
        case .signedInWithHitobito(_, let state):
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
    
    var isAdminSignedIn: Bool {
        switch self {
        case .signedOut(_):
            return false
        case .signedInWithHitobito(let user, _):
            return user.isAdmin
        }
    }
}
