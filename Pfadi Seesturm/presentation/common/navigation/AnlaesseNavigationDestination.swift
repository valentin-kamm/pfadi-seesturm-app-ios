//
//  AnlaesseNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI

enum AnlaesseNavigationDestination: NavigationDestination {
    case detail(inputType: DetailInputType<String, GoogleCalendarEvent>)
    case manageTermin(calendar: SeesturmCalendar, mode: EventManagementMode)
}

private struct AnlaesseNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let accountModule: AccountModule
    private let calendar: SeesturmCalendar
    
    init(
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar
    ) {
        self.wordpressModule = wordpressModule
        self.accountModule = accountModule
        self.calendar = calendar
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: AnlaesseNavigationDestination.self) { destination in
            switch destination {
            case .detail(let input):
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
    
    func anlaesseNavigationDestinations(
        wordpressModule: WordpressModule,
        accountModule: AccountModule,
        calendar: SeesturmCalendar
    ) -> some View {
        self.modifier(
            AnlaesseNavigationDestinations(
                wordpressModule: wordpressModule,
                accountModule: accountModule,
                calendar: calendar
            )
        )
    }
}
