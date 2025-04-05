//
//  TermineDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import SwiftUI

class TermineDetailViewModel: StateManager<UiState<GoogleCalendarEvent>> {
    
    private let service: AnlaesseService
    let input: DetailInputType<String, GoogleCalendarEvent>
    let calendar: SeesturmCalendar
    init(
        service: AnlaesseService,
        input: DetailInputType<String, GoogleCalendarEvent>,
        calendar: SeesturmCalendar
    ) {
        self.service = service
        self.input = input
        self.calendar = calendar
        super.init(initialState: .loading(subState: .idle))
    }
    
    func fetchEvent() async {
        switch input {
        case .id(let id):
            updateState { state in
                state = .loading(subState: .loading)
            }
            let result = await service.fetchEvent(calendar: calendar, eventId: id)
            switch result {
            case .error(let e):
                switch e {
                case .cancelled:
                    updateState { state in
                        state = .loading(subState: .retry)
                    }
                default:
                    updateState { state in
                        state = .error(message: "Der Anlass konnte nicht geladen werden. \(e.defaultMessage)")
                    }
                }
            case .success(let d):
                updateState { state in
                    state = .success(data: d)
                }
            }
        case .object(let object):
            updateState { state in
                state = .success(data: object)
            }
        }
    }
    
}
