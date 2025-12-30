//
//  ProgressActionState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

enum ProgressActionState<D>: SeesturmState {
    case idle
    case loading(action: D, progress: Double)
    case error(action: D, message: String)
    case success(action: D, message: String)
}

extension ProgressActionState {
    
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
        case .loading(_, _):
            return true
        default:
            return false
        }
    }
}
