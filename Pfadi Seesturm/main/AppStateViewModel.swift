//
//  AppStateViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 04.12.2024.
//

import SwiftUI

@MainActor
class AppStateViewModel: ObservableObject {
    
    @Published var selectedTab: AppMainTab = .home
    @Published var tabNavigationPaths: [AppMainTab: NavigationPath] = [
        .home: NavigationPath(),
        .aktuell: NavigationPath(),
        .anlässe: NavigationPath(),
        .mehr: NavigationPath(),
        .account: NavigationPath()
    ]
    @Published var showAppVersionCheckOverlay: Bool = false
    
    private let authService: AuthService
    private let wordpressApi: WordpressApi
    
    init(
        authService: AuthService,
        wordpressApi: WordpressApi
    ) {
        self.authService = authService
        self.wordpressApi = wordpressApi
        
        Task {
            await checkMinimumRequiredAppBuild()
        }
    }
    
    func path(for tab: AppMainTab) -> Binding<NavigationPath> {
        Binding(
            get: { self.tabNavigationPaths[tab] ?? NavigationPath() },
            set: { self.tabNavigationPaths[tab] = $0 }
        )
    }
    
    func navigate(from url: URL) {
        if let universalLink = SeesturmUniversalLink(url: url) {
            if case .oauthCallback = universalLink {
                authService.resumeExternalUserAgentFlow(url: url)
            }
            let tab = universalLink.navigationDestination.0
            let path = universalLink.navigationDestination.1
            setNavigationPath(tab: tab, path: path)
            changeTab(newTab: tab)
        }
    }
    
    func changeTab(newTab: AppMainTab) {
        withAnimation {
            selectedTab = newTab
        }
    }
    func setNavigationPath(tab: AppMainTab, path: NavigationPath) {
        withAnimation {
            tabNavigationPaths[tab] = path
        }
    }
    func appendToNavigationPath(tab: AppMainTab, destination: any Hashable) {
        withAnimation {
            tabNavigationPaths[tab]?.append(destination)
        }
    }
    
    private func checkMinimumRequiredAppBuild() async {
        
        let minimimRequiredBuildResult = try? await wordpressApi.getMinimumRequiredAppBuild()
        let currentBuildResult = (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String).flatMap(Int.init)
        
        if let minRequiredBuild = minimimRequiredBuildResult, let currentBuild = currentBuildResult, currentBuild < minRequiredBuild.ios {
            withAnimation {
                showAppVersionCheckOverlay = true
            }
        }
    }
}
