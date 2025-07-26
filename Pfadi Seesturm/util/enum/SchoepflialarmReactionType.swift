//
//  SchoepflialarmReactionType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import SwiftUI

enum SchoepflialarmReactionType: String, CaseIterable, Identifiable {
    
    case coming
    case notComing
    case alreadyThere
    
    var id: String { rawValue }
    
    init(string: String) throws {
        
        guard let type = SchoepflialarmReactionType(rawValue: string) else {
            throw PfadiSeesturmError.unknownSchoepflialarmReactionType(message: "Unbekannte Reaktions-Art für Schöpflialarm")
        }
        self = type
    }
    
    var sortingOrder: Int {
        switch self {
        case .coming:
            10
        case .notComing:
            30
        case .alreadyThere:
            20
        }
    }
    
    var title: String {
        switch self {
        case .coming:
            "Bin unterwegs"
        case .notComing:
            "Heute nicht"
        case .alreadyThere:
            "Schon da"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .coming:
            "checkmark.circle.fill"
        case .notComing:
            "xmark.circle.fill"
        case .alreadyThere:
            "house.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .coming:
            .SEESTURM_GREEN
        case .notComing:
            .SEESTURM_RED
        case .alreadyThere:
            .primary
        }
    }
    
    var onReactionColor: Color {
        switch self {
        case .coming:
            .white
        case .notComing:
            .white
        case .alreadyThere:
            .customBackground
        }
    }
}
