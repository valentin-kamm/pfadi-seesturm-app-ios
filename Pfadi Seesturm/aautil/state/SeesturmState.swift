//
//  SeesturmState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//

protocol SeesturmState {
    var isError: Bool { get }
    var isSuccess: Bool { get }
}

// handle results from API calls
enum SeesturmResult<D, E: SeesturmError>: SeesturmState {
    case error(E)
    case success(D)
}
extension SeesturmResult {
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
}

// wrapper for user interactions
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

// wrapper for simple UI State (loading, success, error)
enum UiState<D>: SeesturmState {
    case loading(subState: UiLoadingSubState)
    case error(message: String)
    case success(data: D)
}
enum UiLoadingSubState: Hashable {
    case idle
    case retry
    case loading
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
        case .loading(let seesturmUiLoadingSubState):
            switch seesturmUiLoadingSubState {
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
}

// wrapper for infinite scroll UI State
enum InfiniteScrollUiState<D>: SeesturmState {
    case loading(subState: UiLoadingSubState)
    case error(message: String)
    case success(data: D, subState: InfiniteScrollUiSubState)
}
enum InfiniteScrollUiSubState {
    case loading
    case error(message: String)
    case success
}
extension InfiniteScrollUiState {
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
        case .success(_, _):
            return true
        default:
            return false
        }
    }
    
    var taskShouldRun: Bool {
        switch self {
        case .loading(let seesturmUiLoadingSubState):
            switch seesturmUiLoadingSubState {
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
    func updateSubState(_ newSubState: InfiniteScrollUiSubState) -> InfiniteScrollUiState {
        switch self {
        case .success(let data, _):
            return .success(data: data, subState: newSubState)
        default:
            return self
        }
    }
    func updateDataAndSubState(
        _ transform: (D) -> D,
        _ newSubState: InfiniteScrollUiSubState
    ) -> InfiniteScrollUiState {
        switch self {
        case .success(let data, _):
            return .success(data: transform(data), subState: newSubState)
        default:
            return self
        }
    }
}
extension InfiniteScrollUiSubState {
    var infiniteScrollTaskShouldRun: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}
