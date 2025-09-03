//
//  ContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI
import SwiftData

struct MainTabView : View {
    
    @EnvironmentObject private var authState: AuthViewModel
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @AppStorage("theme") private var selectedTheme: String = "system"
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.accountModule) private var accountModule: AccountModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    
    private var appearance: ColorScheme? {
        switch selectedTheme {
        case "hell":
            return .light
        case "dunkel":
            return .dark
        default:
            return .none
        }
    }
            
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            
            HomeView(
                viewModel: HomeViewModel(
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
                        .renderingMode(appState.selectedTab == .home ? .original : .template)
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
            
            AnlaesseView(
                viewModel: AnlaesseViewModel(
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
                viewModel: GalleriesViewModel(
                    service: wordpressModule.photosService,
                    type: .pfadijahre
                )
            )
            .tabItem {
                Label("Mehr", systemImage: "ellipsis.rectangle")
            }
            .tag(AppMainTab.mehr)
            .toolbarBackground(.bar, for: .tabBar)
            
            AccountView(
                authState: authState.authState,
                leiterbereich: { user in
                    let viewModel = LeiterbereichViewModel(
                        leiterbereichService: accountModule.leiterbereichService,
                        schoepflialarmService: accountModule.schoepflialarmService,
                        fcmService: fcmModule.fcmService,
                        user: user,
                        calendar: .termineLeitungsteam
                    )
                    return LeiterbereichView(
                        viewModel: viewModel,
                        user: user,
                        calendar: .termineLeitungsteam
                    )
                    .accountNavigationDestinations(
                        wordpressModule: wordpressModule,
                        accountModule: accountModule,
                        calendar: .termineLeitungsteam,
                        leiterbereichViewModel: viewModel
                    )
                },
                path: appState.path(for: .account),
                onAuthenticate: {
                    await authState.authenticate()
                },
                onResetAuthState: {
                    authState.resetAuthState()
                }
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
            appearance
            : .none
        )
    }
}
