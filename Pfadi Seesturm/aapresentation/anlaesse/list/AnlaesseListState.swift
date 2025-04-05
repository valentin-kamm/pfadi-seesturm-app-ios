//
//  AnlaesseListState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

struct AnlaesseListState {
    var result: InfiniteScrollUiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var lastUpdated: String = ""
    var nextPageToken: String? = nil
}
