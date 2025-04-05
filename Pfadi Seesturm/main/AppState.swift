//
//  AppState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 03.03.2025.
//
import SwiftUI

struct AppState {
    var selectedTab: AppMainTab = .home
    var tabNavigationPaths: [AppMainTab: NavigationPath] = [
        .home: NavigationPath(),
        .aktuell: NavigationPath(),
        .anlässe: NavigationPath(),
        .mehr: NavigationPath(),
        .account: NavigationPath()
    ]
    var authState: AuthState = .signedOut(state: .idle)
}
