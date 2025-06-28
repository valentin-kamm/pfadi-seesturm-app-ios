//
//  SeesturmSnackbarType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//
import SwiftUI

enum SeesturmSnackbarType {
    
    case error
    case info
    case success
    
    init (from: SeesturmBinarySnackbarType) {
        switch from {
        case .error(_, _):
            self = .error
        case .success(_, _):
            self = .success
        }
    }
}

extension SeesturmSnackbarType {
    
    var backgroundColor: Color {
        switch self {
        case .error:
            .SEESTURM_RED
        case .info:
            .SEESTURM_BLUE
        case .success:
            .SEESTURM_GREEN
        }
    }
    
    var icon: Image {
        switch self {
        case .error:
            Image(systemName: "xmark.circle")
        case .info:
            Image(systemName: "info.circle")
        case .success:
            Image(systemName: "checkmark.circle")
        }
    }
}
