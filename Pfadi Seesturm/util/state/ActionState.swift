//
//  ActionState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

enum ActionState<D>: SeesturmState {
    case idle
    case loading(action: D)
    case error(action: D, message: String)
    case success(action: D, message: String)
}

extension ActionState {
    
    var isError: Bool {
        switch self {
        case .error(_, _):
            return true
        default:
            return false
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success(_, _):
            return true
        default:
            return false
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading(_):
            return true
        default:
            return false
        }
    }
}
