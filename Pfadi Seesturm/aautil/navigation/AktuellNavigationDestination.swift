//
//  AktuellNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI
import SwiftData

enum AktuellNavigationDestination: NavigationDestination {
    case detail(inputType: DetailInputType<Int, WordpressPost>)
    case pushNotifications
}

struct AktuellNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let modelContext: ModelContext
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        modelContext: ModelContext
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.modelContext = modelContext
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: AktuellNavigationDestination.self) { destination in
            switch destination {
            case .detail(let input):
                let aktuellDetailView = AktuellDetailView(
                    viewModel: AktuellDetailViewModel(
                        service: wordpressModule.aktuellService,
                        input: input
                    ),
                    pushNavigationLink: {
                        NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                            Image(systemName: "bell.badge")
                        }
                    }
                )
                switch input {
                case .id(let id):
                    aktuellDetailView
                        .id(id)
                case .object(_):
                    aktuellDetailView
                }
            case .pushNotifications:
                PushNotificationVerwaltenView(
                    viewModel: PushNotificationVerwaltenViewModel(
                        service: fcmModule.fcmSubscriptionService,
                        modelContext: modelContext
                    )
                )
            }
        }
    }
}

extension View {
    func aktuellNavigationDestinations(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        modelContext: ModelContext
    ) -> some View {
        self.modifier(
            AktuellNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                modelContext: modelContext
            )
        )
    }
}
