//
//  EventValidationStatus.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.06.2025.
//

enum EventValidationStatus {
    
    case valid
    case warning(message: String)
    case error(message: String)
}
