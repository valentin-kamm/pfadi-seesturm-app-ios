//
//  StufenbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//
import SwiftUI
import Observation

@Observable
@MainActor
class StufenbereichViewModel {
    
    var anAbmeldungenState: UiState<[AktivitaetAnAbmeldung]> = .loading(subState: .idle)
    var aktivitaetenState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var deleteAbmeldungenState: ActionState<GoogleCalendarEventWithAnAbmeldungen> = .idle
    var deleteAllAbmeldungenState: ActionState<Void> = .idle
    var sendPushNotificationState: ActionState<GoogleCalendarEvent> = .idle
    private var _selectedDate: Date = Calendar.current.date(byAdding: .month, value: -3, to: Date()) ?? Date()
    var selectedAktivitaetInteraction: AktivitaetInteractionType = .abmelden
    var showDeleteAllAbmeldungenConfirmationDialog: Bool = false
    var showDeleteAbmeldungenConfirmationDialog: Bool = false
    var showSendPushNotificationConfirmationDialog: Bool = false
    
    var selectedDate: Date {
        get { _selectedDate }
        set {
            _selectedDate = newValue
            Task {
                await reloadAktivitaetenIfNecessary()
            }
        }
    }
    
    private let stufe: SeesturmStufe
    private let service: StufenbereichService
    
    init(
        stufe: SeesturmStufe,
        service: StufenbereichService
    ) {
        self.stufe = stufe
        self.service = service
    }
    
    private var hasLoadedInitialAnAbmeldungen = false
    
    var deleteAbmeldungenContinuation: CheckedContinuation<Bool, Never>?
    var sendPushNotificationContinuation: CheckedContinuation<Bool, Never>?
    
    var abmeldungenState: UiState<[GoogleCalendarEventWithAnAbmeldungen]> {
        switch aktivitaetenState {
        case .loading(let aktivitaetenSubState):
            return .loading(subState: aktivitaetenSubState)
        case .error(let aktivitaetenMessage):
            return .error(message: aktivitaetenMessage)
        case .success(let aktivitaeten):
            
            switch anAbmeldungenState {
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
    private var mustReloadAktivitaeten: Bool {
        if case .success(let aktivitaeten) = aktivitaetenState {
            let endDates = aktivitaeten.map { $0.end }
            if let oldestEndDate = endDates.min(), !endDates.isEmpty {
                return _selectedDate < oldestEndDate
            }
            // array is empty, always reload
            return true
        }
        return false
    }
    func isEditButtonLoading(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) -> Bool {
        
        if case .loading(let event) = deleteAbmeldungenState, aktivitaet == event {
            return true
        }
        if case .loading(let event) = sendPushNotificationState, aktivitaet.event == event {
            return true
        }
        return false
    }
    
    func loadData() async {
        
        var tasks: [() async -> Void] = []
        
        if aktivitaetenState.taskShouldRun {
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
            withAnimation {
                aktivitaetenState = .loading(subState: .loading)
            }
        }
        let result = await service.fetchEvents(stufe: stufe, timeMin: _selectedDate)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    aktivitaetenState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    aktivitaetenState = .error(message: "Aktivitäten der \(stufe.name) konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                aktivitaetenState = .success(data: d)
            }
        }
    }
    
    private func observeAnAbmeldungen() async {
        if !hasLoadedInitialAnAbmeldungen {
            withAnimation {
                anAbmeldungenState = .loading(subState: .loading)
            }
        }
        for await result in service.observeAnAbmeldungen(stufe: stufe) {
            if !hasLoadedInitialAnAbmeldungen {
                hasLoadedInitialAnAbmeldungen = true
            }
            switch result {
            case .error(let e):
                withAnimation {
                    anAbmeldungenState = .error(message: "An- und Abmeldungen konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    anAbmeldungenState = .success(data: d)
                }
            }
        }
    }
    
    func deleteAnAbmeldungenForAktivitaet(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        let isConfirmed = await withCheckedContinuation { continuation in
            self.deleteAbmeldungenContinuation = continuation
            withAnimation {
                showDeleteAbmeldungenConfirmationDialog = true
            }
        }
        
        deleteAbmeldungenContinuation = nil
        
        guard isConfirmed == true else {
            return
        }
        
        withAnimation {
            deleteAbmeldungenState = .loading(action: aktivitaet)
        }
        
        let result = await service.deleteAnAbmeldungen(for: aktivitaet)
        switch result {
        case .error(let e):
            withAnimation {
                deleteAbmeldungenState = .error(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) konnten nicht gelöscht werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                deleteAbmeldungenState = .success(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) erfolgreich gelöscht.")
            }
        }
    }
    
    func sendPushNotification(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        let isConfirmed = await withCheckedContinuation { continuation in
            self.sendPushNotificationContinuation = continuation
            withAnimation {
                showSendPushNotificationConfirmationDialog = true
            }
        }
        
        sendPushNotificationContinuation = nil
        
        guard isConfirmed == true else {
            return
        }
        
        withAnimation {
            sendPushNotificationState = .loading(action: aktivitaet.event)
        }
        
        let result = await service.sendPushNotification(for: stufe, for: aktivitaet.event)
        switch result {
        case .error(let e):
            withAnimation {
                sendPushNotificationState = .error(action: aktivitaet.event, message: "Push-Nachricht für \(aktivitaet.event.title) konnte nicht gesendet werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                sendPushNotificationState = .success(action: aktivitaet.event, message: "Push-Nachricht für \(aktivitaet.event.title) erfolgreich gesendet.")
            }
        }
    }
    
    func deleteAllAnAbmeldungen() async {
        
        if case .success(let data) = anAbmeldungenState {
            
            withAnimation {
                deleteAllAbmeldungenState = .loading(action: ())
            }
            let result = await service.deleteAllPastAnAbmeldungen(stufe: stufe, anAbmeldungen: data)
            switch result {
            case .error(let e):
                withAnimation {
                    deleteAllAbmeldungenState = .error(action: (), message: "An- und Abmeldungen konnten nicht gelöscht werden. \(e.defaultMessage)")
                }
            case .success(_):
                withAnimation {
                    deleteAllAbmeldungenState = .success(action: (), message: "Vergangene An- und Abmeldungen für die \(stufe.name) erfolgreich gelöscht.")
                }
            }
        }
    }
}
