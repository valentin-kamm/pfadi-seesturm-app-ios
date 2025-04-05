//
//  Pfadi_SeesturmApp.swift
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
struct Pfadi_SeesturmApp: App {
    
    private var appDependencies: AppDependencies { AppDependencies() }
    
    init() {
        // set color for page indicators
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .secondaryLabel
        // set up firebase
        configureFirebase()
        configureAppCheck()
    }
    
    var body: some Scene {
        WindowGroup {
            DIView(appDependencies: appDependencies)
        }
    }
}

struct DIView: View {
    
    @StateObject private var appState: AppStateViewModel
    private let appDependencies: AppDependencies
    
    // model container for SwiftData
    var modelContainer: ModelContainer = {
        let schema = Schema([SelectedStufeDao.self, GespeichertePersonDao.self, SubscribedFCMNotificationTopicDao.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            container.seedInitialStufenIfNeeded()
            return container
        }
        catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()
    
    init(appDependencies: AppDependencies) {
        self.appDependencies = appDependencies
        _appState = StateObject(wrappedValue: appDependencies.appState)
    }
    
    var body: some View {
        Group {
            MainTabView()
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

// functions to set up firebase at app start
extension Pfadi_SeesturmApp {

    private func configureAppCheck() {
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(SeesturmAppAttestDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(SeesturmAppAttestProviderFactory())
        #endif
    }
    private func configureFirebase() {
        FirebaseApp.configure()
        /*
        let fileName: String
        #if DEBUG
        fileName = "GoogleService-Info-Debug"
        #else
        fileName = "GoogleService-Info-Release"
        #endif
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "plist") else {
            fatalError("Could not include Firebase in the Project.")
        }
        guard let options = FirebaseOptions(contentsOfFile: filePath) else {
            fatalError("Could not include Firebase in the Project.")
        }
        FirebaseApp.configure(options: options)
         */
    }
}
