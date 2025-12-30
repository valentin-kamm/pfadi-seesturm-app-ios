//
//  ProgressResult.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

enum ProgressResult<D>: SeesturmState {
    case loading(progress: Double)
    case error(message: String)
    case success(data: D, message: String)
}

extension ProgressResult {
    
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
    
    var isLoading: Bool {
        switch self {
        case .loading(_):
            return true
        default:
            return false
        }
    }
}
