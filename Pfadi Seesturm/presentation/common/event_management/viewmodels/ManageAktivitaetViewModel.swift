//
//  ManageAktivitaetViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.01.2026.
//
import SwiftUI
import Observation

@Observable
@MainActor
class ManageAktivitaetViewModel: EventManagementController, PushNotificationCapableEventController, TemplatesCapableEventController, UpdateCapableEventController {
    
    var templatesState: UiState<[AktivitaetTemplate]> = .loading(subState: .idle)
    var sendPushNotification: Bool = true
    var showTemplatesSheet: Bool = false
    
    private let service: StufenbereichService
    let stufe: SeesturmStufe
    
    init(
        service: StufenbereichService,
        stufe: SeesturmStufe
    ) {
        self.service = service
        self.stufe = stufe
    }
    
    var eventPreviewType: EventPreviewType {
        .aktivitaet(stufe: self.stufe)
    }
    
    func validateEvent(event: CloudFunctionEventPayload, isAllDay: Bool, trimmedDescription: String, mode: EventManagementMode) -> EventValidationStatus {
        
        // errors
        if event.end < event.start {
            return .error(message: "Das Enddatum darf nicht vor dem Startdatum sein.")
        }
        if event.summary.isEmpty {
            return .error(message: "Der Titel darf nicht leer sein.")
        }
        
        // warnings
        if abs(Calendar.current.dateComponents([.hour], from: event.start, to: event.end).hour ?? 2) < 2 && !isAllDay {
            return .warning(message: "Die Aktivität ist kürzer als 2 Stunden. Möchtest du die Aktivität trotzdem \(mode.verb)?")
        }
        if event.start < Date.now {
            return .warning(message: "Das Startdatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(mode.verb)?")
        }
        if event.end < Date.now {
            return .warning(message: "Das Enddatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(mode.verb)?")
        }
        if trimmedDescription.isEmpty {
            return .warning(message: "Die Beschreibung ist leer. Möchtest du die Aktivität trotzdem \(mode.verb)?")
        }
        if event.location.isEmpty {
            return .warning(message: "Der Treffpunkt ist leer. Möchtest du die Aktivität trotzdem \(mode.verb)?")
        }
        
        return .valid
    }
    
    func addEvent(event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError> {
        return await service.addNewAktivitaet(event: event, stufe: self.stufe, withNotification: self.sendPushNotification)
    }
    
    func fetchEvent(eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        return await service.fetchEvent(stufe: self.stufe, eventId: eventId)
    }
    
    func updateEvent(eventId: String, event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError> {
        return await service.updateExistingAktivitaet(eventId: eventId, event: event, stufe: self.stufe, withNotification: self.sendPushNotification)
    }
    
    func observeTemplates() async {
        
        withAnimation {
            self.templatesState = .loading(subState: .loading)
        }
        
        for await result in service.observeAktivitaetTemplates(stufe: self.stufe) {
            switch result {
            case .error(let e):
                withAnimation {
                    templatesState = .error(message: "Die Vorlagen für die \(stufe.name) konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    templatesState = .success(data: d)
                }
            }
        }
    }
}
