//
//  SeesturmAuthState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//

enum SeesturmAuthState: Equatable {
    
    case signedOut(state: SignedOutState)
    case signedInWithHitobito(user: FirebaseHitobitoUser, state: SignedInWithHitobitoState)
    
    enum SignedOutState: Equatable {
        
        case idle
        case signingInWithHitobito
        case error(message: String)
    }
    
    enum SignedInWithHitobitoState: Equatable {
        
        case idle
        case signingOut
        case deletingAccount
        case error(message: String)
    }
    
    static func == (lhs: SeesturmAuthState, rhs: SeesturmAuthState) -> Bool {
        switch (lhs, rhs) {
        case (.signedOut(let l), .signedOut(let r)):
            return l == r
        case (.signedOut(_), .signedInWithHitobito(_, _)):
            return false
        case (.signedInWithHitobito(_, _), .signedOut(_)):
            return false
        case (.signedInWithHitobito(_, let l), .signedInWithHitobito(_, let r)):
            return l == r
        }
    }
}

extension SeesturmAuthState.SignedOutState {
    
    static func == (lhs: SeesturmAuthState.SignedOutState, rhs: SeesturmAuthState.SignedOutState) -> Bool {
        switch (lhs, rhs) {
        case (SeesturmAuthState.SignedOutState.idle, SeesturmAuthState.SignedOutState.idle):
            return true
        case (SeesturmAuthState.SignedOutState.signingInWithHitobito, SeesturmAuthState.SignedOutState.signingInWithHitobito):
            return true
        case (SeesturmAuthState.SignedOutState.error(_), SeesturmAuthState.SignedOutState.error(_)):
            return true
            
        case (SeesturmAuthState.SignedOutState.idle, SeesturmAuthState.SignedOutState.signingInWithHitobito):
            return false
        case (SeesturmAuthState.SignedOutState.idle, SeesturmAuthState.SignedOutState.error(_)):
            return false
        case (SeesturmAuthState.SignedOutState.signingInWithHitobito, SeesturmAuthState.SignedOutState.idle):
            return false
        case (SeesturmAuthState.SignedOutState.signingInWithHitobito, SeesturmAuthState.SignedOutState.error(_)):
            return false
        case (SeesturmAuthState.SignedOutState.error(_), SeesturmAuthState.SignedOutState.idle):
            return false
        case (SeesturmAuthState.SignedOutState.error(_), SeesturmAuthState.SignedOutState.signingInWithHitobito):
            return false
        }
    }
}

extension SeesturmAuthState.SignedInWithHitobitoState {
    
    static func == (lhs: SeesturmAuthState.SignedInWithHitobitoState, rhs: SeesturmAuthState.SignedInWithHitobitoState) -> Bool {
        switch (lhs, rhs) {
        case (SeesturmAuthState.SignedInWithHitobitoState.idle, SeesturmAuthState.SignedInWithHitobitoState.idle):
            return true
        case (SeesturmAuthState.SignedInWithHitobitoState.deletingAccount, SeesturmAuthState.SignedInWithHitobitoState.deletingAccount):
            return true
        case (SeesturmAuthState.SignedInWithHitobitoState.signingOut, SeesturmAuthState.SignedInWithHitobitoState.signingOut):
            return true
        case (SeesturmAuthState.SignedInWithHitobitoState.error(_), SeesturmAuthState.SignedInWithHitobitoState.error(_)):
            return true
            
        case (SeesturmAuthState.SignedInWithHitobitoState.idle, SeesturmAuthState.SignedInWithHitobitoState.deletingAccount):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.idle, SeesturmAuthState.SignedInWithHitobitoState.signingOut):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.idle, SeesturmAuthState.SignedInWithHitobitoState.error(_)):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.deletingAccount, SeesturmAuthState.SignedInWithHitobitoState.idle):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.deletingAccount, SeesturmAuthState.SignedInWithHitobitoState.signingOut):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.deletingAccount, SeesturmAuthState.SignedInWithHitobitoState.error(_)):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.signingOut, SeesturmAuthState.SignedInWithHitobitoState.idle):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.signingOut, SeesturmAuthState.SignedInWithHitobitoState.deletingAccount):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.signingOut, SeesturmAuthState.SignedInWithHitobitoState.error(_)):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.error(_), SeesturmAuthState.SignedInWithHitobitoState.idle):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.error(_), SeesturmAuthState.SignedInWithHitobitoState.deletingAccount):
            return false
        case (SeesturmAuthState.SignedInWithHitobitoState.error(_), SeesturmAuthState.SignedInWithHitobitoState.signingOut):
            return false
        }
    }
}

extension SeesturmAuthState {
    
    var showInfoSnackbar: Bool {
        switch self {
        case .signedOut(let state):
            switch state {
            case .idle:
                return true
            case .signingInWithHitobito, .error(_):
                return false
            }
        case .signedInWithHitobito(_, _):
            return false
        }
    }
    
    var signInButtonIsLoading: Bool {
        switch self {
        case .signedOut(let state):
            switch state {
            case .signingInWithHitobito:
                return true
            case .idle, .error(_):
                return false
            }
        case .signedInWithHitobito(_, _):
            return false
        }
    }
    
    var signOutButtonIsLoading: Bool {
        switch self {
        case .signedInWithHitobito(_, let state):
            switch state {
            case .signingOut, .deletingAccount:
                return true
            case .idle, .error(_):
                return false
            }
        case .signedOut(_):
            return false
        }
    }
    
    var userToObserve: FirebaseHitobitoUser? {
        switch self {
        case .signedInWithHitobito(let user, let state):
            switch state {
            case .idle, .error(_):
                return user
            case .signingOut, .deletingAccount:
                return nil
            }
        case .signedOut(_):
            return nil
        }
    }
}
