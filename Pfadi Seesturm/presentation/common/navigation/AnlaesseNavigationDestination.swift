//
//  AnlaesseNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI

enum AnlaesseNavigationDestination: NavigationDestination {
    case detail(inputType: DetailInputType<String, GoogleCalendarEvent>)
    case manageTermin(mode: EventManagementMode)
}

private struct AnlaesseNavigationDestinations: ViewModifier {
    
    private let appState: AppStateViewModel
    private let wordpressModule: WordpressModule
    private let calendar: SeesturmCalendar
    
    init(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        calendar: SeesturmCalendar
    ) {
        self.appState = appState
        self.wordpressModule = wordpressModule
        self.calendar = calendar
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: AnlaesseNavigationDestination.self) { destination in
            switch destination {
            case .detail(let input):
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
                                tab: .anlässe,
                                destination: AnlaesseNavigationDestination.manageTermin(mode: .update(eventId: id))
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
                                tab: .anlässe,
                                destination: AnlaesseNavigationDestination.manageTermin(mode: .update(eventId: event.id))
                            )
                        }
                    )
                }
            case .manageTermin(let mode):
                ManageEventView(eventType: .termin(calendar: .termine, mode: mode))
            }
        }
    }
}

extension View {
    
    func anlaesseNavigationDestinations(
        appState: AppStateViewModel,
        wordpressModule: WordpressModule,
        calendar: SeesturmCalendar
    ) -> some View {
        self.modifier(
            AnlaesseNavigationDestinations(
                appState: appState,
                wordpressModule: wordpressModule,
                calendar: calendar
            )
        )
    }
}
