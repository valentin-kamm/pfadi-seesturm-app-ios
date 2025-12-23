//
//  UiState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

enum UiState<D>: SeesturmState {
    case loading(subState: UiLoadingSubState)
    case error(message: String)
    case success(data: D)
}

extension UiState {
    
    var isError: Bool {
        switch self {
        case .error(_):
            return true
        default:
            return false
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success(_):
            return true
        default:
            return false
        }
    }
    
    var taskShouldRun: Bool {
        switch self {
        case .loading(let subState):
            switch subState {
            case .idle, .retry:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    var scrollingDisabled: Bool {
        switch self {
        case .loading(_):
            return true
        default:
            return false
        }
    }
    
    var isLoading: Bool {
        switch self {
        case .loading(let subState):
            switch subState {
            case .loading:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}
