//
//  StufenbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

class StufenbereichViewModel: StateManager<StufenbereichState> {
    
    private let stufe: SeesturmStufe
    private let service: StufenbereichService
    private let initialSheetMode: StufenbereichSheetMode
    
    init(
        stufe: SeesturmStufe,
        service: StufenbereichService,
        initialSheetMode: StufenbereichSheetMode
    ) {
        self.stufe = stufe
        self.service = service
        self.initialSheetMode = initialSheetMode
        super.init(
            initialState: StufenbereichState(
                initialSelectedDate: Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date(),
                initialSheetMode: initialSheetMode
            )
        )
    }
    
    var deleteAbmeldungenContinuation: CheckedContinuation<Bool, Never>?
    var sendPushNotificationContinuation: CheckedContinuation<Bool, Never>?
    
    // detect changes in selectedDate
    override func updateState(_ block: (inout StufenbereichState) -> Void) {
        let oldState = state
        super.updateState { state in
            block(&state)
        }
        if oldState.selectedDate != state.selectedDate {
            Task {
                await reloadAktivitaetenIfNecessary()
            }
        }
    }
    
    var abmeldungenState: UiState<[GoogleCalendarEventWithAnAbmeldungen]> {
        switch state.aktivitaetenState {
        case .loading(let aktivitaetenSubState):
            return .loading(subState: aktivitaetenSubState)
        case .error(let aktivitaetenMessage):
            return .error(message: aktivitaetenMessage)
        case .success(let aktivitaeten):
            switch state.anAbmeldungenState {
            case .loading(let abmeldungenSubState):
                return .loading(subState: abmeldungenSubState)
            case .error(message: let abmeldungenMessage):
                return .error(message: abmeldungenMessage)
            case .success(data: let abmeldungen):
                let combined = aktivitaeten.map { $0.toAktivitaetWithAnAbmeldungen(anAbmeldungen: abmeldungen) }
                return .success(data: combined)
            }
        }
    }
    var selectedAktivitaetInteractionBinding: Binding<AktivitaetInteraction> {
        Binding(
            get: { self.state.selectedAktivitaetInteraction },
            set: { newValue in
                self.updateSelectedAktivitaetInteraction(newInteraction: newValue)
            }
        )
    }
    var selectedDateBinding: Binding<Date> {
        Binding(
            get: { self.state.selectedDate },
            set: { newValue in
                self.updateState { state in
                    state.selectedDate = newValue
                }
            }
        )
    }
    var deleteAbmeldungenStateBinding: Binding<ActionState<GoogleCalendarEventWithAnAbmeldungen>> {
        Binding(
            get: { self.state.deleteAbmeldungenState },
            set: { newValue in
                self.updateState { state in
                    state.deleteAbmeldungenState = newValue
                }
            }
        )
    }
    var deleteAllAbmeldungenStateBinding: Binding<ActionState<Void>> {
        Binding(
            get: { self.state.deleteAllAbmeldungenState },
            set: { newValue in
                self.updateState { state in
                    state.deleteAllAbmeldungenState = newValue
                }
            }
        )
    }
    var sendPushNotificationStateBinding: Binding<ActionState<GoogleCalendarEvent>> {
        Binding(
            get: { self.state.sendPushNotificationState },
            set: { newValue in
                self.updateState { state in
                    state.sendPushNotificationState = newValue
                }
            }
        )
    }
    private var mustReloadAktivitaeten: Bool {
        if case .success(let aktivitaeten) = state.aktivitaetenState {
            let endDates = aktivitaeten.map { $0.endDate }
            if let oldestEndDate = endDates.min(), !endDates.isEmpty {
                return state.selectedDate < oldestEndDate
            }
            // array is empty, always reload
            return true
        }
        return false
    }
    var showSheetBinding: Binding<Bool> {
        Binding(
            get: {
                switch self.state.selectedSheetMode {
                case .hidden:
                    return false
                default:
                    return true
                }
            },
            set: { isShown in
                if !isShown {
                    self.updateSheetMode(newMode: .hidden)
                }
            }
        )
    }
    var showDeleteAllAbmeldungenConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showDeleteAllAbmeldungenConfirmationDialog },
            set: { isVisible in
                self.updateShowDeleteAllAbmeldungenConfirmationDialog(isVisible: isVisible)
            }
        )
    }
    var showDeleteAbmeldungenConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showDeleteAbmeldungenConfirmationDialog },
            set: { isVisible in
                self.updateState { state in
                    state.showDeleteAbmeldungenConfirmationDialog = isVisible
                }
            }
        )
    }
    var showSendPushNotificationConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showSendPushNotificationConfirmationDialog },
            set: { isVisible in
                self.updateState { state in
                    state.showSendPushNotificationConfirmationDialog = isVisible
                }
            }
        )
    }
    func isEditButtonLoading(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) -> Bool {
        if case .loading(let event) = state.deleteAbmeldungenState, aktivitaet == event {
            return true
        }
        if case .loading(let event) = state.sendPushNotificationState, aktivitaet.event == event {
            return true
        }
        return false
    }
    
    var publishAktivitaetStateBinding: Binding<ActionState<Void>> {
        Binding(
            get: { self.state.publishAktivitaetState },
            set: { newValue in
                self.updateState { state in
                    state.publishAktivitaetState = newValue
                }
            }
        )
    }
    
    func loadData() async {
        
        var tasks: [() async -> Void] = []
        
        if state.aktivitaetenState.taskShouldRun {
            tasks.append {
                await self.getAktivitaeten(isPullToRefresh: false)
            }
        }
        tasks.append {
            await self.observeAnAbmeldungen()
        }
        
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    func refresh() async {
        await getAktivitaeten(isPullToRefresh: true)
    }
    
    private func reloadAktivitaetenIfNecessary() async {
        if mustReloadAktivitaeten {
            await getAktivitaeten(isPullToRefresh: false)
        }
    }
    
    func getAktivitaeten(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state.aktivitaetenState = .loading(subState: .loading)
            }
        }
        let result = await service.fetchEvents(stufe: stufe, timeMin: state.selectedDate)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.aktivitaetenState = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.aktivitaetenState = .error(message: "Aktivitäten der \(stufe.stufenName) konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.aktivitaetenState = .success(data: d)
            }
        }
    }
    
    private func observeAnAbmeldungen() async {
        updateState { state in
            state.anAbmeldungenState = .loading(subState: .loading)
        }
        for await result in service.observeAnAbmeldungen(stufe: stufe) {
            switch result {
            case .error(let e):
                updateState { state in
                    state.anAbmeldungenState = .error(message: "An- und Abmeldungen konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                updateState { state in
                    state.anAbmeldungenState = .success(data: d)
                }
            }
        }
    }
    
    func deleteAnAbmeldungenForAktivitaet(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        let isConfirmed = await withCheckedContinuation { continuation in
            self.deleteAbmeldungenContinuation = continuation
            updateState { state in
                state.showDeleteAbmeldungenConfirmationDialog = true
            }
        }
        
        deleteAbmeldungenContinuation = nil
        
        guard isConfirmed == true else {
            return
        }
        
        updateState { state in
            state.deleteAbmeldungenState = .loading(action: aktivitaet)
        }
        let result = await service.deleteAnAbmeldungen(aktivitaet: aktivitaet)
        switch result {
        case .error(let e):
            updateState { state in
                state.deleteAbmeldungenState = .error(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) konnten nicht gelöscht werden. \(e.defaultMessage)")
            }
        case .success(_):
            updateState { state in
                state.deleteAbmeldungenState = .success(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) erfolgreich gelöscht.")
            }
        }
    }
    
    func sendPushNotification(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        let isConfirmed = await withCheckedContinuation { continuation in
            self.sendPushNotificationContinuation = continuation
            updateState { state in
                state.showSendPushNotificationConfirmationDialog = true
            }
        }
        
        sendPushNotificationContinuation = nil
        
        guard isConfirmed == true else {
            return
        }
        
        let result = await service.sendPushNotification(stufe: stufe, aktivitaet: aktivitaet.event)
        switch result {
        case .error(let e):
            updateState { state in
                state.sendPushNotificationState = .error(action: aktivitaet.event, message: "Push-Nachricht für \(aktivitaet.event.title) konnte nicht gesendet werden. \(e.defaultMessage)")
            }
        case .success(_):
            updateState { state in
                state.sendPushNotificationState = .success(action: aktivitaet.event, message: "Push-Nachricht für \(aktivitaet.event.title) erfolgreich gesendet.")
            }
        }
    }
    
    func deleteAllAnAbmeldungen() async {
        
        if case .success(let data) = state.anAbmeldungenState {
            updateState { state in
                state.deleteAllAbmeldungenState = .loading(action: ())
            }
            let result = await service.deleteAllPastAnAbmeldungen(stufe: stufe, anAbmeldungen: data)
            switch result {
            case .error(let e):
                updateState { state in
                    state.deleteAllAbmeldungenState = .error(action: (), message: "An- und Abmeldungen konnten nicht gelöscht werden. \(e.defaultMessage)")
                }
            case .success(_):
                updateState { state in
                    state.deleteAllAbmeldungenState = .success(action: (), message: "Vergangene An- und Abmeldungen für die \(stufe.stufenName) erfolgreich gelöscht.")
                }
            }
        }
        else {
            updateState { state in
                state.deleteAllAbmeldungenState = .error(action: (), message: "An- und Abmeldungen konnten nicht gelöscht werden. Die Daten wurden noch nicht geladen.")
            }
        }
    }
    
    func updateSheetMode(newMode: StufenbereichSheetMode) {
        updateState { state in
            state.selectedSheetMode = newMode
        }
    }
    
    func updateSelectedAktivitaetInteraction(newInteraction: AktivitaetInteraction) {
        updateState { state in
            state.selectedAktivitaetInteraction = newInteraction
        }
    }
    
    func updateShowDeleteAllAbmeldungenConfirmationDialog(isVisible: Bool) {
        updateState { state in
            state.showDeleteAllAbmeldungenConfirmationDialog = isVisible
        }
    }
    
    func updatePublishAktivitaetState(newState: ActionState<Void>) {
        updateState { state in
            state.publishAktivitaetState = newState
        }
    }
}
