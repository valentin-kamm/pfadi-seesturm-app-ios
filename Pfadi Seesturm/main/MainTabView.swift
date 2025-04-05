//
//  ContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI
import SwiftData

struct MainTabView : View {
    
    // view model for navigation
    @EnvironmentObject var appState: AppStateViewModel
    
    @Environment(\.modelContext) var modelContext: ModelContext
    
    // selected appearance
    @AppStorage("theme") var selectedTheme: String = "system"
    
    // di modules
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
            
    var body: some View {
        TabView(selection: appState.selectedTabBinding) {
            HomeView(
                viewModel: HomeViewModel(
                    modelContext: modelContext,
                    calendar: .termine,
                    naechsteAktivitaetService: wordpressModule.naechsteAktivitaetService,
                    aktuellService: wordpressModule.aktuellService,
                    anlaesseService: wordpressModule.anlaesseService,
                    weatherService: wordpressModule.weatherService
                ),
                calendar: .termine
            )
            .tabItem {
                VStack {
                    Image("LogoTabbar")
                        .renderingMode(appState.state.selectedTab == .home ? .original : .template)
                    Text("Home")
                }
            }
            .tag(AppMainTab.home)
            .toolbarBackground(.bar, for: .tabBar)
            AktuellView(
                viewModel: AktuellViewModel(
                    service: wordpressModule.aktuellService
                )
            )
            .tabItem {
                Label("Aktuell", systemImage: "newspaper")
            }
            .tag(AppMainTab.aktuell)
            .toolbarBackground(.bar, for: .tabBar)
            TermineView(
                viewModel: TermineViewModel(
                    service: wordpressModule.anlaesseService,
                    calendar: .termine
                ),
                calendar: .termine
            )
            .tabItem {
                Label("Anlässe", systemImage: "calendar")
            }
            .tag(AppMainTab.anlässe)
            .toolbarBackground(.bar, for: .tabBar)
            MehrView(
                viewModel: PfadijahreViewModel(
                    service: wordpressModule.photosService
                )
            )
            .tabItem {
                Label("Mehr", systemImage: "ellipsis.rectangle")
            }
            .tag(AppMainTab.mehr)
            .toolbarBackground(.bar, for: .tabBar)
            AccountView(
                calendar: .termineLeitungsteam
            )
            .tabItem {
                Label("Account", systemImage: "person.crop.circle")
            }
            .tag(AppMainTab.account)
            .toolbarBackground(.bar, for: .tabBar)
        }
        .accentColor(Color.SEESTURM_GREEN)
        // there is a bug in iOS 18.0
        // -> always return nil for this case
        .preferredColorScheme(
            !(ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 18 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 0) ?
            getAppearance(selectedTheme: selectedTheme)
            : .none
        )
    }
    
    // function to return the appearance depending on the app storage value
    private func getAppearance(selectedTheme: String) -> ColorScheme? {
        switch selectedTheme {
        case "hell":
            return .light
        case "dunkel":
            return .dark
        default:
            return .none
        }
    }
}
