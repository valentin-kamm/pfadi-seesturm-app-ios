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
    
    private let stufe: SeesturmStufe
    private let service: StufenbereichService
    
    init(
        stufe: SeesturmStufe,
        service: StufenbereichService
    ) {
        self.stufe = stufe
        self.service = service
    }
    
    // loading data
    private var anAbmeldungenState: UiState<[AktivitaetAnAbmeldung]> = .loading(subState: .idle)
    private var aktivitaetenState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var state: UiState<[GoogleCalendarEventWithAnAbmeldungen]> {
        switch aktivitaetenState {
        case .loading(let aktivitaetenSubState):
            return .loading(subState: aktivitaetenSubState)
        case .error(let aktivitaetenMessage):
            return .error(message: aktivitaetenMessage)
        case .success(let aktivitaeten):
            
            switch anAbmeldungenState {
            case .loading(let abmeldungenSubState):
                return .loading(subState: abmeldungenSubState)
            case .error(let abmeldungenMessage):
                return .error(message: abmeldungenMessage)
            case .success(let abmeldungen):
                let combined = aktivitaeten.map { $0.toAktivitaetWithAnAbmeldungen(anAbmeldungen: abmeldungen) }
                return .success(data: combined)
            }
        }
    }
    
    // action on single event
    var deleteAbmeldungenState: ActionState<GoogleCalendarEventWithAnAbmeldungen> = .idle
    var sendPushNotificationState: ActionState<GoogleCalendarEventWithAnAbmeldungen> = .idle
    func isEditButtonLoading(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) -> Bool {
        if case .loading(let event) = deleteAbmeldungenState, aktivitaet == event {
            return true
        }
        if case .loading(let event) = sendPushNotificationState, aktivitaet == event {
            return true
        }
        return false
    }
    
    // global actions
    var deleteAllAbmeldungenState: ActionState<Void> = .idle
    var showDeleteAllAbmeldungenConfirmationDialog: Bool = false
    
    // other state
    private var _selectedDate: Date = {
        let calendar = Calendar.current
        let todayAtMidnight = calendar.startOfDay(for: Date())
        let threeMonthsAgoAtMidnight = calendar.date(byAdding: .month, value: -3, to: todayAtMidnight) ?? todayAtMidnight
        return threeMonthsAgoAtMidnight
    }()
    var selectedDate: Date {
        get { _selectedDate }
        set {
            // react to events where a new date is set
            _selectedDate = newValue
            Task {
                await reloadDataIfNecessary()
            }
        }
    }
    private var mustReloadData: Bool {
        // when selecting a new date in the date picker, this variable determines if the data must be fetched again or not
        if case .success(let aktivitaeten) = aktivitaetenState {
            // get all end dates
            let endDates = aktivitaeten.map { $0.end }
            if let oldestEndDate = endDates.min(), !endDates.isEmpty {
                // if the oldest end date is after the selected date, reload the data
                return _selectedDate < oldestEndDate
            }
            // array is empty, always reload since we have no end dates to compare against
            return true
        }
        // data is still loading, do not reload
        return false
    }
}

extension StufenbereichViewModel {
    
    func loadData(isPullToRefresh: Bool, force: Bool) async {
        
        let shouldLoadData = aktivitaetenState.taskShouldRun || anAbmeldungenState.taskShouldRun || force
        
        guard shouldLoadData else {
            return
        }
        
        await getAktivitaeten(isPullToRefresh: isPullToRefresh)
        
        guard case .success(let aktivitaeten) = aktivitaetenState else {
            return
        }
        
        await getAnAbmeldungen(for: aktivitaeten, isPullToRefresh: isPullToRefresh)
    }
    
    private func reloadDataIfNecessary() async {
        
        guard mustReloadData else { return }
        await loadData(isPullToRefresh: false, force: true)
    }
    
    func refresh() async {
        await loadData(isPullToRefresh: true, force: true)
    }
    
    private func getAktivitaeten(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                self.aktivitaetenState = .loading(subState: .loading)
            }
        }
        
        let result = await service.fetchEvents(stufe: stufe, timeMin: _selectedDate)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    self.aktivitaetenState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    self.aktivitaetenState = .error(message: "Aktivitäten der \(stufe.name) konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                self.aktivitaetenState = .success(data: d)
            }
        }
    }
    
    private func getAnAbmeldungen(for aktivitaeten: [GoogleCalendarEvent], isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                self.anAbmeldungenState = .loading(subState: .loading)
            }
        }
        
        let result = await service.fetchAnAbmeldungen(for: aktivitaeten, stufe: stufe)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    self.anAbmeldungenState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    self.anAbmeldungenState = .error(message: "An- und Abmeldungen konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                self.anAbmeldungenState = .success(data: d)
            }
        }
    }
    
    func deleteAnAbmeldungen(for aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        withAnimation {
            self.deleteAbmeldungenState = .loading(action: aktivitaet)
        }
        
        let result = await service.deleteAnAbmeldungen(for: aktivitaet)
        
        switch result {
        case .error(let e):
            withAnimation {
                self.deleteAbmeldungenState = .error(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) konnten nicht gelöscht werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                self.deleteAbmeldungenState = .success(action: aktivitaet, message: "An- und Abmeldungen für \(aktivitaet.event.title) erfolgreich gelöscht.")
            }
        }
    }
    
    func sendPushNotification(for aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async {
        
        withAnimation {
            self.sendPushNotificationState = .loading(action: aktivitaet)
        }
        
        let result = await service.sendPushNotification(for: stufe, for: aktivitaet.event)
        
        switch result {
        case .error(let e):
            withAnimation {
                self.sendPushNotificationState = .error(action: aktivitaet, message: "Push-Nachricht für \(aktivitaet.event.title) konnte nicht gesendet werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                self.sendPushNotificationState = .success(action: aktivitaet, message: "Push-Nachricht für \(aktivitaet.event.title) erfolgreich gesendet.")
            }
        }
    }
    
    func deleteAllAnAbmeldungen() async {
        
        guard case .success(let data) = anAbmeldungenState else {
            return
        }
        
        withAnimation {
            self.deleteAllAbmeldungenState = .loading(action: ())
        }
        
        let result = await service.deleteAllPastAnAbmeldungen(stufe: stufe, anAbmeldungen: data)
        
        switch result {
        case .error(let e):
            withAnimation {
                self.deleteAllAbmeldungenState = .error(action: (), message: "An- und Abmeldungen konnten nicht gelöscht werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                self.deleteAllAbmeldungenState = .success(action: (), message: "Vergangene An- und Abmeldungen für die \(stufe.name) erfolgreich gelöscht.")
            }
        }
    }
}
