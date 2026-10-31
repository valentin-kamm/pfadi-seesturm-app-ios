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
    var disableForm: Bool = false
    var description: String = "" {
        didSet {
            trimmedDescription = description.htmlTrimmed
        }
    }
    @ObservationIgnored
    private var trimmedDescription = ""
    
    private let initialEventType: EventToManageType
    var eventType: EventToManageType
    private let controller: C
    
    init(
        eventType: EventToManageType,
        controller: C
    ) {
        self.initialEventType = eventType
        self.controller = controller
        
        switch self.initialEventType {
        case .aktivitaet(let stufe, _):
            self.title = stufe.aktivitaetDescription
            self.start = DateTimeUtil.shared.nextSaturday(at: 14, timeZone: TimeZone(identifier: "Europe/Zurich")!)
            self.end = DateTimeUtil.shared.nextSaturday(at: 16, timeZone: TimeZone(identifier: "Europe/Zurich")!)
        case .multipleAktivitaeten:
            self.title = ""
            self.start = DateTimeUtil.shared.nextSaturday(at: 14, timeZone: TimeZone(identifier: "Europe/Zurich")!)
            self.end = DateTimeUtil.shared.nextSaturday(at: 16, timeZone: TimeZone(identifier: "Europe/Zurich")!)
        case .termin(_, _):
            self.title = ""
            let calendar = Calendar.current
            let now = Date()
            let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0, second: 0), matchingPolicy: .nextTime) ?? now
            let inTwoHours = calendar.date(byAdding: .hour, value: 2, to: nextHour) ?? now
            self.start = nextHour
            self.end = inTwoHours
        }
        
        switch self.initialEventType.mode {
        case .insert:
            self.eventState = .success(data: ())
        case .update(_):
            self.eventState = .loading(subState: .idle)
        }
        
        self.eventType = initialEventType
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
        controller.validateEvent(event: self.eventForPublishing, isAllDay: self.isAllDay, trimmedDescription: self.trimmedDescription, mode: self.eventType.mode)
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
            case .aktivitaet(let stufe, _):
                return "Die \(stufe.aktivitaetDescription) wird \(self.sendPushNotification ? "mit" : "ohne") Push-Nachricht \(self.eventType.mode.verbPassiv)."
            case .multipleAktivitaeten:
                return "Die Aktivität wird \(self.sendPushNotification ? "mit" : "ohne") Push-Nachricht \(self.eventType.mode.verbPassiv)."
            case .termin(_, _):
                return "Möchtest du den Anlass wirklich \(self.eventType.mode.verb)?"
            }
        case .warning(let message), .error(let message):
            return message
        }
    }
    var confirmationDialogConfirmButtonText: String {
        switch self.publishingValidationStatus {
        case .valid:
            return self.eventType.mode.nomen
        case .warning(_), .error(_):
            return "Trotzdem \(self.eventType.mode.verb)"
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
        
        guard case .update(let eventId) = self.eventType.mode else {
            return
        }
        guard let c = self.controller as? UpdateCapableEventController else {
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
        
        let result: SeesturmResult<AddEventSubsequentAction, CloudFunctionsError>
        
        switch self.eventType.mode {
        case .insert:
            withAnimation {
                self.publishEventState = .loading(action: ())
            }
            result = await self.controller.addEvent(event: self.eventForPublishing)
        case .update(let eventId):
            guard let c = self.controller as? UpdateCapableEventController else {
                return
            }
            withAnimation {
                self.publishEventState = .loading(action: ())
            }
            let r = await c.updateEvent(eventId: eventId, event: self.eventForPublishing)
            switch r {
            case .error(let e):
                result = .error(e)
            case .success(_):
                result = .success(.none)
            }
        }
        
        switch result {
        case .error(let e):
            let message: String
            switch self.eventType {
            case .aktivitaet(let stufe, _):
                message = "Beim \(self.eventType.mode.nomen) der \(stufe.aktivitaetDescription) \(self.sendPushNotification ? "oder beim Senden der Push-Nachricht " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            case .multipleAktivitaeten:
                message = "Beim \(self.eventType.mode.nomen) der Aktivitäten \(self.sendPushNotification ? "oder beim Senden der Push-Nachrichten " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            case .termin(_, _):
                message = "Beim \(self.eventType.mode.nomen) des Anlasses \(self.sendPushNotification ? "oder beim Senden der Push-Nachricht " : "")ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
            withAnimation {
                self.publishEventState = .error(action: (), message: message)
            }
        case .success(let action):
            let message: String
            switch self.eventType {
            case .aktivitaet(let stufe, _):
                message = "\(stufe.aktivitaetDescription) erfolgreich \(self.eventType.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachricht gesendet." : "")"
            case .multipleAktivitaeten:
                message = "Aktivitäten erfolgreich \(self.eventType.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachrichten gesendet." : "")"
            case .termin(_, _):
                message = "Anlass erfolgreich \(self.eventType.mode.verbPassiv).\(self.sendPushNotification ? " Push-Nachricht gesendet." : "")"
            }
            withAnimation {
                self.publishEventState = .success(action: (), message: message)
            }
            
            // um zu vermeiden, dass Events aus Versehen mehrfach veröffentlich werden, wird bei Bedarf der Modus auf Update geändert oder die Bearbeitung ganz gesperrt
            switch action {
            case .switchToUpdateMode(let newEventId):
                self.eventType = self.eventType.with(newMode: .update(eventId: newEventId))
            case .lock:
                self.disableForm = true
            case .none:
                break
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
