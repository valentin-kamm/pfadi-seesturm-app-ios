//
//  ManageEventViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.01.2026.
//
import SwiftUI
import Observation

@Observable
@MainActor
class ManageEventViewModel<C: EventManagementController> {
    
    var eventState: UiState<Void>
    var publishEventState: ActionState<Void> = .idle
    var title: String
    var location: String = ""
    var start: Date
    var end: Date
    var isAllDay: Bool = false
    var showConfirmationDialog: Bool = false
    var showPreviewSheet: Bool = false
    var description: String = "" {
        didSet {
            trimmedDescription = description.htmlTrimmed
        }
    }
    @ObservationIgnored
    private var trimmedDescription = ""
    
    let eventType: EventToManageType
    private let controller: C
    let mode: EventManagementMode
    
    init(
        eventType: EventToManageType,
        controller: C
    ) {
        self.eventType = eventType
        self.controller = controller
        
        switch self.eventType {
        case .aktivitaet(let stufe, let mode):
            self.mode = mode
            self.title = stufe.aktivitaetDescription
            self.start = DateTimeUtil.shared.nextSaturday(at: 14, timeZone: TimeZone(identifier: "Europe/Zurich")!)
            self.end = DateTimeUtil.shared.nextSaturday(at: 16, timeZone: TimeZone(identifier: "Europe/Zurich")!)
        case .multipleAktivitaeten:
            self.mode = .insert
            self.title = ""
            self.start = DateTimeUtil.shared.nextSaturday(at: 14, timeZone: TimeZone(identifier: "Europe/Zurich")!)
            self.end = DateTimeUtil.shared.nextSaturday(at: 16, timeZone: TimeZone(identifier: "Europe/Zurich")!)
        case .termin(_, let mode):
            self.mode = mode
            self.title = ""
            let calendar = Calendar.current
            let now = Date()
            let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime) ?? now
            let inTwoHours = calendar.date(byAdding: .hour, value: 2, to: nextHour) ?? now
            self.start = nextHour
            self.end = inTwoHours
        }
        
        switch self.mode {
        case .insert:
            self.eventState = .success(data: ())
        case .update(_):
            self.eventState = .loading(subState: .idle)
        }
    }
    
    private var eventForPublishing: CloudFunctionEventPayload {
        return CloudFunctionEventPayload(
            summary: self.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: self.location.trimmingCharacters(in: .whitespacesAndNewlines),
            isAllDay: self.isAllDay,
            start: self.isAllDay ? Calendar.current.startOfDay(for: self.start) : self.start,
            end: self.isAllDay ? Calendar.current.startOfDay(for: self.end) : self.end
        )
    }
    var eventForPreview: GoogleCalendarEvent? {
        try? self.eventForPublishing.toGoogleCalendarEvent()
    }
    private var publishingValidationStatus: EventValidationStatus {
        controller.validateEvent(event: self.eventForPublishing, isAllDay: self.isAllDay, trimmedDescription: self.trimmedDescription, mode: self.mode)
    }
    
    var eventPreviewType: EventPreviewType {
        controller.eventPreviewType
    }
    
    var templatesState: UiState<[AktivitaetTemplate]>? {
        guard let c = self.controller as? TemplatesCapableEventController else {
            return nil
        }
        return c.templatesState
    }
    
    private var sendPushNotification: Bool {
        guard let c = self.controller as? PushNotificationCapableEventController else {
            return false
        }
        return c.sendPushNotification
    }
    
    var confirmationDialogTitle: String {
        switch self.publishingValidationStatus {
        case .valid:
            switch self.eventType {
            case .aktivitaet(_, _), .multipleAktivitaeten:
                return "Die Aktivität wird \(self.sendPushNotification ? "mit" : "ohne") Push-Nachricht \(self.mode.verbPassiv)."
            case .termin(_, _):
                return "Möchtest du den Anlass wirklich \(self.mode.verb)?"
            }
        case .warning(let message), .error(let message):
            return message
        }
    }
    var confirmationDialogConfirmButtonText: String {
        switch self.publishingValidationStatus {
        case .valid:
            return self.mode.nomen
        case .warning(_), .error(_):
            return "Trotzdem \(self.mode.verb)"
        }
    }
    
    var previewSheetItem: Binding<GoogleCalendarEvent?> {
        Binding(
            get: {
                guard self.showPreviewSheet else {
                    return nil
                }
                return self.eventForPreview
            },
            set: {
                guard $0 == nil else {
                    return
                }
                self.showPreviewSheet = false
            }
        )
    }
    var showTemplatesSheet: Binding<Bool>? {
        guard let c = self.controller as? TemplatesCapableEventController else {
            return nil
        }
        return Binding(
            get: { c.showTemplatesSheet },
            set: { c.showTemplatesSheet = $0 }
        )
    }
    var pushNotificationBinding: Binding<Bool>? {
        guard let c = self.controller as? PushNotificationCapableEventController else {
            return nil
        }
        return Binding(
            get: { c.sendPushNotification },
            set: { c.sendPushNotification = $0 }
        )
    }
    var selectedStufenBinding: Binding<Set<SeesturmStufe>>? {
        guard let c = self.controller as? MultiStufenCapableEventController else {
            return nil
        }
        return Binding(
            get: { c.selectedStufen },
            set: { c.selectedStufen = $0 }
        )
    }
    
    var onShowTemplatesSheet: (() -> Void)? {
        guard let c = self.controller as? TemplatesCapableEventController else {
            return nil
        }
        return { c.showTemplatesSheet = true }
    }
    
    func fetchEventIfPossible() async {
        
        guard let c = self.controller as? UpdateCapableEventController else {
            return
        }
        guard case .update(let eventId) = mode else {
            return
        }
        guard self.eventState.taskShouldRun else {
            return
        }
        
        withAnimation {
            self.eventState = .loading(subState: .loading)
        }
        
        let result = await c.fetchEvent(eventId: eventId)
        
        switch result {
        case .error(let e):
            let message: String
            switch self.eventType {
            case .aktivitaet(let stufe, _):
                message = "\(stufe.aktivitaetDescription) konnte nicht geladen werden. \(e.defaultMessage)"
            case .multipleAktivitaeten:
                message = "Aktivität konnte nicht geladen werden. \(e.defaultMessage)"
            case .termin(_, _):
                message = "Anlass konnte nicht geladen werden. \(e.defaultMessage)"
            }
            withAnimation {
                self.eventState = .error(message: message)
            }
        case .success(let d):
            withAnimation {
                self.title = d.title
                self.description = d.description ?? ""
                self.location = d.location ?? ""
                self.start = d.start
                self.end = d.end
                self.isAllDay = d.isAllDay
                self.eventState = .success(data: ())
            }
        }
    }
    
    func trySubmit() {
        
        switch self.publishingValidationStatus {
        case .error(let message):
            withAnimation {
                self.publishEventState = .error(action: (), message: message)
            }
        case .warning(_), .valid:
            self.showConfirmationDialog = true
        }
    }
    
    func submit() async {
        
        switch self.mode {
        case .insert:
            await executeInsertOrUpdate {
                await self.controller.addEvent(event: self.eventForPublishing)
            }
        case .update(let eventId):
            guard let c = self.controller as? UpdateCapableEventController else {
                break
            }
            await executeInsertOrUpdate {
                await c.updateEvent(eventId: eventId, event: self.eventForPublishing)
            }
        }
    }
    
    private func executeInsertOrUpdate(execute: () async -> SeesturmResult<Void, CloudFunctionsError>) async {
        
        withAnimation {
            self.publishEventState = .loading(action: ())
        }
        
        let result = await execute()
        
        switch result {
        case .error(let e):
            let message: String
            switch self.eventType {
            case .aktivitaet(let stufe, _):
                message = "Beim \(self.mode.nomen) der \(stufe.aktivitaetDescription) \(self.sendPushNotification ? "oder beim Senden der Push-Nachricht " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            case .multipleAktivitaeten:
                message = "Beim \(self.mode.nomen) der Aktivitäten \(self.sendPushNotification ? "oder beim Senden der Push-Nachrichten " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            case .termin(_, _):
                message = "Beim \(self.mode.nomen) des Anlasses \(self.sendPushNotification ? "oder beim Senden der Push-Nachricht " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
            withAnimation {
                self.publishEventState = .error(action: (), message: message)
            }
        case .success(_):
            let message: String
            switch self.eventType {
            case .aktivitaet(let stufe, _):
                message = "\(stufe.aktivitaetDescription) erfolgreich \(self.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachricht gesendet." : "")"
            case .multipleAktivitaeten:
                message = "Aktivitäten erfolgreich \(self.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachrichten gesendet." : "")"
            case .termin(_, _):
                message = "Anlass erfolgreich \(self.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachricht gesendet." : "")"
            }
            withAnimation {
                self.publishEventState = .success(action: (), message: message)
            }
        }
    }
    
    func observeTemplatesIfPossible() async {
        guard let c = self.controller as? TemplatesCapableEventController else {
            return
        }
        await c.observeTemplates()
    }
    
    func useTemplateIfPossible(_ template: AktivitaetTemplate) {
        guard let c = self.controller as? TemplatesCapableEventController else {
            return
        }
        self.description = template.description
        c.showTemplatesSheet = false
    }
}
