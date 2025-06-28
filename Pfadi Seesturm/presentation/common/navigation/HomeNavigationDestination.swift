//
//  HomeNavigationDestinations.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI
import SwiftData

enum HomeNavigationDestination: NavigationDestination {
    
    case aktivitaetDetail(inputType: DetailInputType<String, GoogleCalendarEvent?>, stufe: SeesturmStufe)
    case aktuellDetail(inputType: DetailInputType<Int, WordpressPost>)
    case anlassDetail(inputType: DetailInputType<String, GoogleCalendarEvent>)
    case pushNotifications
}

private struct HomeNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let authModule: AuthModule
    private let calendar: SeesturmCalendar
    
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        calendar: SeesturmCalendar
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.authModule = authModule
        self.calendar = calendar
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: HomeNavigationDestination.self) { destination in
            switch destination {
            case .aktuellDetail(let input):
                AktuellDetailView(
                    viewModel: AktuellDetailViewModel(
                        service: wordpressModule.aktuellService,
                        input: input
                    ),
                    pushNotificationsNavigationDestination: HomeNavigationDestination.pushNotifications
                )
            case .anlassDetail(let input):
                TermineDetailView(
                    viewModel: TermineDetailViewModel(
                        service: wordpressModule.anlaesseService,
                        input: input,
                        calendar: calendar
                    ),
                    calendar: calendar
                )
            case .pushNotifications:
                PushNotificationVerwaltenView(
                    viewModel: PushNotificationVerwaltenViewModel(
                        service: fcmModule.fcmService
                    )
                )
            case .aktivitaetDetail(let input, let stufe):
                let aktivitaetDetailView = AktivitaetDetailView(
                    viewModel: AktivitaetDetailViewModel(
                        input: input,
                        service: wordpressModule.naechsteAktivitaetService,
                        stufe: stufe,
                        userId: authModule.authRepository.getCurrentUid()
                    ),
                    stufe: stufe,
                    type: .home
                )
                switch input {
                case .id(let id):
                    aktivitaetDetailView
                        .id(id)
                case .object(_):
                    aktivitaetDetailView
                }
            }
        }
    }
}

extension View {
    
    func homeNavigationDestinations(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        calendar: SeesturmCalendar
    ) -> some View {
        self.modifier(
            HomeNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                authModule: authModule,
                calendar: calendar
            )
        )
    }
}
