//
//  AktivitaetDetailState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//

struct AktivitaetDetailState {
    var loadingState: UiState<GoogleCalendarEvent?> = .loading(subState: .idle)
    var anAbmeldenState: ActionState<AktivitaetInteraction> = .idle
    var showSheet: Bool = false
    var selectedSheetMode: AktivitaetInteraction = .abmelden
    var vorname: String = ""
    var nachname: String = ""
    var pfadiname: String = ""
    var bemerkung = ""
}
