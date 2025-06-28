//
//  InfiniteScrollUiSubState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

enum InfiniteScrollUiSubState {
    case loading
    case error(message: String)
    case success
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
