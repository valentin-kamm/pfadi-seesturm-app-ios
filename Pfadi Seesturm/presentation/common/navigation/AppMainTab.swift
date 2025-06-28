//
//  AppMainTab.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//

enum AppMainTab: Identifiable {
    
    case home
    case aktuell
    case anlässe
    case mehr
    case account
    
    var id: Int {
        switch self {
        case .home:
            return 0
        case .aktuell:
            return 1
        case .anlässe:
            return 2
        case .mehr:
            return 3
        case .account:
            return 4
        }
    }
}
