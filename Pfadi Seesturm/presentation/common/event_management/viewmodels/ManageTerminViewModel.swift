//
//  ManageTerminViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.01.2026.
//
import SwiftUI
import Observation

@Observable
@MainActor
class ManageTerminViewModel: EventManagementController, UpdateCapableEventController {
    
    private let service: AnlaesseService
    let calendar: SeesturmCalendar
    
    init(
        service: AnlaesseService,
        calendar: SeesturmCalendar
    ) {
        self.service = service
        self.calendar = calendar
    }
    
    var eventPreviewType: EventPreviewType {
        .termin(calendar: self.calendar)
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
        if event.start < Date.now {
            return .warning(message: "Das Startdatum ist in der Vergangenheit. Möchtest du den Anlass trotzdem \(mode.verb)?")
        }
        if event.end < Date.now {
            return .warning(message: "Das Enddatum ist in der Vergangenheit. Möchtest du den Anlass trotzdem \(mode.verb)?")
        }
        if trimmedDescription.isEmpty {
            return .warning(message: "Die Beschreibung ist leer. Möchtest du den Anlass trotzdem \(mode.verb)?")
        }
        if event.location.isEmpty {
            return .warning(message: "Der Treffpunkt ist leer. Möchtest du den Anlass trotzdem \(mode.verb)?")
        }
        
        return .valid
    }
    
    func addEvent(event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError> {
        return await service.addEvent(event: event, calendar: self.calendar)
    }
    
    func fetchEvent(eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        return await service.fetchEvent(calendar: self.calendar, eventId: eventId)
    }
    
    func updateEvent(eventId: String, event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError> {
        return await service.updateEvent(eventId: eventId, event: event, calendar: self.calendar)
    }
}
