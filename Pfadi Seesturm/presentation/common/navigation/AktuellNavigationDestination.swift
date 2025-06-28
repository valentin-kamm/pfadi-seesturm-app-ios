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

private struct AktuellNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
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
                    pushNotificationsNavigationDestination: AktuellNavigationDestination.pushNotifications
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
                        service: fcmModule.fcmService
                    )
                )
            }
        }
    }
}

extension View {
    
    func aktuellNavigationDestinations(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule
    ) -> some View {
        self.modifier(
            AktuellNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule
            )
        )
    }
}
