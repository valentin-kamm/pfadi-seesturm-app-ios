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
    case manageTermin(eventId: String)
}

private struct HomeNavigationDestinations: ViewModifier {
    
    private let appState: AppStateViewModel
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let authModule: AuthModule
    private let accountModule: AccountModule
    private let calendar: SeesturmCalendar
    
    init(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar
    ) {
        self.appState = appState
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.authModule = authModule
        self.accountModule = accountModule
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
                switch input {
                case .id(let id):
                    TermineDetailView(
                        viewModel: TermineDetailViewModel(
                            service: wordpressModule.anlaesseService,
                            input: input,
                            calendar: calendar
                        ),
                        calendar: calendar,
                        onEditEvent: {
                            appState.appendToNavigationPath(
                                tab: .home,
                                destination: HomeNavigationDestination.manageTermin(eventId: id)
                            )
                        }
                    )
                    .id(id)
                case .object(let event):
                    TermineDetailView(
                        viewModel: TermineDetailViewModel(
                            service: wordpressModule.anlaesseService,
                            input: input,
                            calendar: calendar
                        ),
                        calendar: calendar,
                        onEditEvent: {
                            appState.appendToNavigationPath(
                                tab: .home,
                                destination: HomeNavigationDestination.manageTermin(eventId: event.id)
                            )
                        }
                    )
                }
            case .pushNotifications:
                PushNotificationVerwaltenView(
                    viewModel: PushNotificationVerwaltenViewModel(
                        service: fcmModule.fcmService
                    )
                )
            case .aktivitaetDetail(let input, let stufe):
                let aktivitaetDetailView = AktivitaetDetailView(
                    stufe: stufe,
                    type: .home(input: input),
                    userId: authModule.authRepository.getCurrentUid(),
                    service: wordpressModule.naechsteAktivitaetService
                )
                switch input {
                case .id(let id):
                    aktivitaetDetailView
                        .id(id)
                case .object(_):
                    aktivitaetDetailView
                }
            case .manageTermin(let eventId):
                ManageEventView(
                    viewModel: ManageEventViewModel(
                        stufenbereichService: accountModule.stufenbereichService,
                        anlaesseService: wordpressModule.anlaesseService,
                        eventType: .termin(calendar: calendar, mode: .update(eventId: eventId))
                    )
                )
            }
        }
    }
}

extension View {
    
    func homeNavigationDestinations(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar
    ) -> some View {
        self.modifier(
            HomeNavigationDestinations(
                appState: appState,
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                authModule: authModule,
                accountModule: accountModule,
                calendar: calendar
            )
        )
    }
}
