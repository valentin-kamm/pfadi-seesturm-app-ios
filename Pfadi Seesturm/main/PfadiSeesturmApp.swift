//
//  PfadiSeesturmApp.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.09.2024.
//

import SwiftUI
import SwiftData
import FirebaseMessaging
import FirebaseCore
import FirebaseAppCheck

@main
struct PfadiSeesturmApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    private let appDependencies: AppDependencies = AppDependencies(modelContext: ModelContext(seesturmModelContainer))
    
    init() {
        // set color for page indicators
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .secondaryLabel
    }
    
    var body: some Scene {
        WindowGroup {
            DIView(
                appDependencies: appDependencies,
                modelContainer: seesturmModelContainer
            )
        }
    }
}

private struct DIView: View {
    
    @StateObject private var appState: AppStateViewModel
    @AppStorage("showOnboardingView\(Constants.ONBOARDING_SCREEN_VERSION)") private var showOnboardingScreen: Bool = true
    private let appDependencies: AppDependencies
    private let modelContainer: ModelContainer
        
    init(
        appDependencies: AppDependencies,
        modelContainer: ModelContainer
    ) {
        self.appDependencies = appDependencies
        self.modelContainer = modelContainer
        _appState = StateObject(wrappedValue: appDependencies.appState)
    }
    
    var body: some View {
        Group {
            MainTabView()
            .disabled(appState.showAppVersionCheckOverlay || showOnboardingScreen)
            // show error if app version is below required version
            .overlay {
                if appState.showAppVersionCheckOverlay {
                    UpdateRequiredView()
                }
            }
            // show onboarding screen on first app launch
            .overlay {
                if showOnboardingScreen {
                    OnboardingView(
                        viewModel: PushNotificationVerwaltenViewModel(
                            service: appDependencies.fcmModule.fcmService
                        )
                    )
                }
            }
        }
        // SwiftData
        .modelContainer(modelContainer)
        // main app state
        .environmentObject(appState)
        // DI Modules
        .environment(\.authModule, appDependencies.authModule)
        .environment(\.wordpressModule, appDependencies.wordpressModule)
        .environment(\.fcmModule, appDependencies.fcmModule)
        .environment(\.firestoreModule, appDependencies.firestoreModule)
        .environment(\.accountModule, appDependencies.accountModule)
        // open any links in SFSafariViewController
        .handleOpenURLInApp()
        // handle universal links
        .onOpenURL { url in
            appState.navigate(from: url)
        }
    }
}
