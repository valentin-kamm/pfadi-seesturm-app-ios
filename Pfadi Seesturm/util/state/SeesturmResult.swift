//
//  SeesturmResult.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

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
