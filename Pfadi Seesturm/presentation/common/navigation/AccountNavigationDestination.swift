//
//  AccountNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI

enum AccountNavigationDestination: NavigationDestination {
    
    case food(user: FirebaseHitobitoUser)
    case anlaesse
    case anlassDetail(inputType: DetailInputType<String, GoogleCalendarEvent>)
    case stufenbereich(stufe: SeesturmStufe)
    case displayAktivitaet(stufe: SeesturmStufe, aktivitaet: GoogleCalendarEvent)
    case manageEvent(type: EventToManageType)
    case templates(stufe: SeesturmStufe)
}

private struct AccountNavigationDestinations: ViewModifier {
    
    private let appState: AppStateViewModel
    private let wordpressModule: WordpressModule
    private let accountModule: AccountModule
    private let calendar: SeesturmCalendar
    private let leiterbereichViewModel: LeiterbereichViewModel
    
    init(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar,
        leiterbereichViewModel: LeiterbereichViewModel
    ) {
        self.appState = appState
        self.wordpressModule = wordpressModule
        self.accountModule = accountModule
        self.calendar = calendar
        self.leiterbereichViewModel = leiterbereichViewModel
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: AccountNavigationDestination.self) { destination in
            switch destination {
            case .displayAktivitaet(let stufe, let aktivitaet):
                AktivitaetDetailView(
                    stufe: stufe,
                    type: .stufenbereich(event: aktivitaet),
                    userId: nil,
                    service: wordpressModule.naechsteAktivitaetService
                )
            case .anlaesse:
                AnlaesseView(
                    viewModel: AnlaesseViewModel(
                        service: wordpressModule.anlaesseService,
                        calendar: calendar
                    ),
                    calendar: calendar
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
                                tab: .account,
                                destination: AccountNavigationDestination.manageEvent(type: .termin(calendar: calendar, mode: .update(eventId: id)))
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
                                tab: .account,
                                destination: AccountNavigationDestination.manageEvent(type: .termin(calendar: calendar, mode: .update(eventId: event.id)))
                            )
                        }
                    )
                }
            case .stufenbereich(let stufe):
                StufenbereichView(
                    viewModel: StufenbereichViewModel(
                        stufe: stufe,
                        service: accountModule.stufenbereichService
                    ),
                    stufe: stufe
                )
            case .food(let user):
                OrdersView(
                    viewModel: leiterbereichViewModel,
                    user: user
                )
            case .manageEvent(let type):
                ManageEventView(eventType: type)
            case .templates(let stufe):
                TemplateEditListView(
                    viewModel: TemplateViewModel(
                        stufe: stufe,
                        service: accountModule.stufenbereichService
                    ),
                    stufe: stufe
                )
            }
        }
    }
}

extension View {
    
    func accountNavigationDestinations(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar,
        leiterbereichViewModel: LeiterbereichViewModel
    ) -> some View {
        self.modifier(
            AccountNavigationDestinations(
                appState: appState,
                wordpressModule: wordpressModule,
                accountModule: accountModule,
                calendar: calendar,
                leiterbereichViewModel: leiterbereichViewModel
            )
        )
    }
}
