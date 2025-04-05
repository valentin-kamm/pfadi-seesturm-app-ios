//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.01.2025.
//
struct HomeListState {
    var addRemoveStufenState: ActionState<SeesturmStufe> = .idle
    var naechsteAktivitaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>] = [:]
    var selectedStufen: UiState<Set<SeesturmStufe>> = .loading(subState: .idle)
    var aktuellState: UiState<WordpressPost> = .loading(subState: .idle)
    var anlaesseState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var weatherState: UiState<Weather> = .loading(subState: .idle)
}
