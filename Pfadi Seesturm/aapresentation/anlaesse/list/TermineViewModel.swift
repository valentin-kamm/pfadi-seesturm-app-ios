//
//  TermineViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//

import SwiftUI

class TermineViewModel: StateManager<AnlaesseListState> {
    
    private let numberOfEventsPerPage: Int = 10
    private let calendar: SeesturmCalendar
    
    private let service: AnlaesseService
    init(
        service: AnlaesseService,
        calendar: SeesturmCalendar
    ) {
        self.service = service
        self.calendar = calendar
        super.init(initialState: AnlaesseListState())
    }
    
    var hasMoreEvents: Bool {
        return state.nextPageToken != nil
    }
    
    // function to fetch the initial set of posts
    func getEvents(isPullToRefresh: Bool) async {
        if !isPullToRefresh {
            updateState { state in
                state.result = .loading(subState: .loading)
            }
        }
        let result = await service.fetchEvents(calendar: calendar, includePast: false, maxResults: numberOfEventsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.result = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.result = .error(message: "Anlässe konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.result = .success(data: d.items, subState: .success)
                state.nextPageToken = d.nextPageToken
                state.lastUpdated = d.updated
            }
        }
    }
    
    func getMoreEvents() async {
        
        guard let nextPage = state.nextPageToken else {
            updateState { state in
                state.result = .error(message: "Es konnten keine weiteren Anlässe geladen werden, da die nächste Seite unbekannt ist.")
            }
            return
        }
        updateState { state in
            state.result = state.result.updateSubState(.loading)
        }
        let result = await service.fetchMoreEvents(calendar: calendar, pageToken: nextPage, maxResults: numberOfEventsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.result = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.result = state.result.updateSubState(.error(message: "Es konnten nicht mehr Anlässe geladen werden. \(e.defaultMessage)"))
                }
            }
        case .success(let d):
            updateState { state in
                state.result = state.result.updateDataAndSubState(
                    { oldData in
                        return oldData + d.items
                    },
                    .success
                )
                state.nextPageToken = d.nextPageToken
                state.lastUpdated = d.updated
            }
        }
    }
}
