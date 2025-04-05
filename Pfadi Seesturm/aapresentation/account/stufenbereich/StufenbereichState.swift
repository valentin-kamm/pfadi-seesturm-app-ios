//
//  StufenbereichState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import Foundation

struct StufenbereichState {
    var anAbmeldungenState: UiState<[AktivitaetAnAbmeldung]> = .loading(subState: .idle)
    var aktivitaetenState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var publishAktivitaetState: ActionState<Void> = .idle
    var deleteAbmeldungenState: ActionState<GoogleCalendarEventWithAnAbmeldungen> = .idle
    var deleteAllAbmeldungenState: ActionState<Void> = .idle
    var sendPushNotificationState: ActionState<GoogleCalendarEvent> = .idle
    var selectedSheetMode: StufenbereichSheetMode
    var selectedDate: Date
    var selectedAktivitaetInteraction: AktivitaetInteraction = .abmelden
    var showDeleteAllAbmeldungenConfirmationDialog: Bool = false
    var showDeleteAbmeldungenConfirmationDialog: Bool = false
    var showSendPushNotificationConfirmationDialog: Bool = false
    
    init(
        initialSelectedDate: Date,
        initialSheetMode: StufenbereichSheetMode
    ) {
        self.selectedDate = initialSelectedDate
        self.selectedSheetMode = initialSheetMode
    }
}
