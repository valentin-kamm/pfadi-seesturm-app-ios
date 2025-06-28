//
//  TermineDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

import SwiftUI
import Observation

@Observable
@MainActor
class TermineDetailViewModel {
    
    var terminState: UiState<GoogleCalendarEvent>
    
    private let service: AnlaesseService
    private let input: DetailInputType<String, GoogleCalendarEvent>
    private let calendar: SeesturmCalendar
    
    init(
        service: AnlaesseService,
        input: DetailInputType<String, GoogleCalendarEvent>,
        calendar: SeesturmCalendar
    ) {
        self.service = service
        self.input = input
        self.calendar = calendar
        
        switch input {
        case .id(_):
            self.terminState = .loading(subState: .idle)
        case .object(let object):
            self.terminState = .success(data: object)
        }
    }
    
    func fetchEvent() async {
        
        guard case .id(let id) = input else {
            return
        }

        withAnimation {
            terminState = .loading(subState: .loading)
        }
        
        let result = await service.fetchEvent(calendar: calendar, eventId: id)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    terminState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    terminState = .error(message: "Der Anlass konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                terminState = .success(data: d)
            }
        }
    }
}
