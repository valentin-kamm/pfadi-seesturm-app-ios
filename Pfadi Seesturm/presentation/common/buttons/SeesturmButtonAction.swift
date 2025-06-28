//
//  SeesturmButtonAction.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

enum SeesturmButtonAction {
    case none
    case sync(action: () -> Void)
    case async(action: () async -> Void)
}
