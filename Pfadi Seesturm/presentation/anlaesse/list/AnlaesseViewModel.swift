//
//  AnlaesseViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//
import SwiftUI
import Observation

@Observable
@MainActor
class AnlaesseViewModel {
    
    var eventsState: InfiniteScrollUiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var lastUpdated: String = ""
    var nextPageToken: String? = nil
    
    private let calendar: SeesturmCalendar
    private let service: AnlaesseService
    
    init(
        service: AnlaesseService,
        calendar: SeesturmCalendar
    ) {
        self.service = service
        self.calendar = calendar
    }
    
    private let numberOfEventsPerPage: Int = 10
    
    var hasMoreEvents: Bool {
        return nextPageToken != nil
    }
    
    func getEvents(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                eventsState = .loading(subState: .loading)
            }
        }
        
        let result = await service.fetchEvents(calendar: calendar, includePast: false, maxResults: numberOfEventsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    eventsState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    eventsState = .error(message: "Anlässe konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                eventsState = .success(data: d.items, subState: .success)
                nextPageToken = d.nextPageToken
                lastUpdated = d.updatedFormatted
            }
        }
    }
    
    func getMoreEvents() async {
        
        guard let nextPage = nextPageToken else {
            withAnimation {
                eventsState = .error(message: "Es konnten keine weiteren Anlässe geladen werden, da die nächste Seite unbekannt ist.")
            }
            return
        }
        
        withAnimation {
            eventsState = eventsState.updateSubState(.loading)
        }
        let result = await service.fetchMoreEvents(calendar: calendar, pageToken: nextPage, maxResults: numberOfEventsPerPage)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    eventsState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    eventsState = eventsState.updateSubState(.error(message: "Es konnten keine weiteren Anlässe geladen werden. \(e.defaultMessage)"))
                }
            }
        case .success(let d):
            withAnimation {
                nextPageToken = d.nextPageToken
                lastUpdated = d.updatedFormatted
                eventsState = eventsState.updateDataAndSubState(
                    { oldData in
                        return oldData + d.items
                    },
                    .success
                )
            }
        }
    }
}
