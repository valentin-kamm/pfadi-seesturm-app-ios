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
    case stufenbereich(stufe: SeesturmStufe, initialSheetMode: StufenbereichSheetMode)
}

struct AccountNavigationDestinations: ViewModifier {
    
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
            case .anlaesse:
                TermineView(
                    viewModel: TermineViewModel(
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
            case .stufenbereich(let stufe, let initialSheetMode):
                StufenbereichView(
                    viewModel: StufenbereichViewModel(
                        stufe: stufe,
                        service: accountModule.stufenbereichService,
                        initialSheetMode: initialSheetMode
                    ),
                    stufe: stufe
                )
            case .food(let user):
                EssenBestellenView(
                    viewModel: leiterbereichViewModel,
                    user: user
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
