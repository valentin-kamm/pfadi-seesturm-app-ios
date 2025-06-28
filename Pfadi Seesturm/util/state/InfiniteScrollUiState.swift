//
//  InfiniteScrollUiState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

enum InfiniteScrollUiState<D>: SeesturmState {
    case loading(subState: UiLoadingSubState)
    case error(message: String)
    case success(data: D, subState: InfiniteScrollUiSubState)
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
