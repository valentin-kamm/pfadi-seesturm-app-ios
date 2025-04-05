//
//  AnlaesseNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI

enum AnlaesseNavigationDestination: NavigationDestination {
    case detail(inputType: DetailInputType<String, GoogleCalendarEvent>)
}

struct AnlaesseNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let calendar: SeesturmCalendar
    init(
        wordpressModule: WordpressModule,
        calendar: SeesturmCalendar
    ) {
        self.wordpressModule = wordpressModule
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
            }
        }
    }
}

extension View {
    func anlaesseNavigationDestinations(
        wordpressModule: WordpressModule,
        calendar: SeesturmCalendar
    ) -> some View {
        self.modifier(
            AnlaesseNavigationDestinations(
                wordpressModule: wordpressModule,
                calendar: calendar
            )
        )
    }
}
