//
//  SeesturmButtonType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//
import SwiftUI

enum SeesturmButtonType {
    
    case primary
    case secondary
    
    var predefinedButtonColor: Color {
        switch self {
        case .primary:
            return .SEESTURM_RED
        case .secondary:
            return .SEESTURM_GREEN
        }
    }
    var predefinedContentColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .white
        }
    }
    var horizontalPadding: CGFloat {
        switch self {
        case .primary:
            16
        case .secondary:
            12
        }
    }
    var verticalPadding: CGFloat {
        switch self {
        case .primary:
            12
        case .secondary:
            8
        }
    }
}
