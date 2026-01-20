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
    case aktivitaetBearbeiten(type: EventToManageType)
    case templates(stufe: SeesturmStufe)
    case manageTermin(calendar: SeesturmCalendar, mode: EventManagementMode)
}

private struct AccountNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let accountModule: AccountModule
    private let calendar: SeesturmCalendar
    private let leiterbereichViewModel: LeiterbereichViewModel
    
    init(
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar,
        leiterbereichViewModel: LeiterbereichViewModel
    ) {
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
                let termineDetailView = TermineDetailView(
                    viewModel: TermineDetailViewModel(
                        service: wordpressModule.anlaesseService,
                        input: input,
                        calendar: calendar
                    ),
                    calendar: calendar
                )
                switch input {
                case .id(let id):
                    termineDetailView
                        .id(id)
                case .object(_):
                    termineDetailView
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
            case .aktivitaetBearbeiten(let type):
                ManageEventView(
                    viewModel: ManageEventViewModel(
                        stufenbereichService: accountModule.stufenbereichService,
                        anlaesseService: wordpressModule.anlaesseService,
                        eventType: type
                    )
                )
            case .templates(let stufe):
                TemplateEditListView(
                    viewModel: TemplateViewModel(
                        stufe: stufe,
                        service: accountModule.stufenbereichService
                    ),
                    stufe: stufe
                )
            case .manageTermin(let calendar, let mode):
                ManageEventView(
                    viewModel: ManageEventViewModel(
                        stufenbereichService: accountModule.stufenbereichService,
                        anlaesseService: wordpressModule.anlaesseService,
                        eventType: .termin(calendar: calendar, mode: mode)
                    )
                )
            }
        }
    }
}

extension View {
    
    func accountNavigationDestinations(
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar,
        leiterbereichViewModel: LeiterbereichViewModel
    ) -> some View {
        self.modifier(
            AccountNavigationDestinations(
                wordpressModule: wordpressModule,
                accountModule: accountModule,
                calendar: calendar,
                leiterbereichViewModel: leiterbereichViewModel
            )
        )
    }
}
