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

struct HomeNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let authModule: AuthModule
    private let calendar: SeesturmCalendar
    private let modelContext: ModelContext
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        calendar: SeesturmCalendar,
        modelContext: ModelContext
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.authModule = authModule
        self.calendar = calendar
        self.modelContext = modelContext
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
                    pushNavigationLink: {
                        NavigationLink(value: HomeNavigationDestination.pushNotifications) {
                            Image(systemName: "bell.badge")
                        }
                    }
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
                        service: fcmModule.fcmSubscriptionService,
                        modelContext: modelContext
                    )
                )
            case .aktivitaetDetail(let input, let stufe):
                AktivitaetDetailView(
                    viewModel: AktivitaetDetailViewModel(
                        service: wordpressModule.naechsteAktivitaetService,
                        input: input,
                        stufe: stufe,
                        userId: authModule.authService.getCurrentUid()
                    ),
                    stufe: stufe,
                    isPreview: false
                )
            }
        }
    }
}

extension View {
    func homeNavigationDestinations(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        authModule: AuthModule,
        calendar: SeesturmCalendar,
        modelContext: ModelContext
    ) -> some View {
        self.modifier(
            HomeNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                authModule: authModule,
                calendar: calendar,
                modelContext: modelContext
            )
        )
    }
}
