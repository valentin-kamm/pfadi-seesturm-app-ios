//
//  AktivitätBearbeitenViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class AktivitaetBearbeitenViewModel {
    
    var aktivitaetState: UiState<Void>
    var publishAktivitaetState: ActionState<Void> = .idle
    var title: String
    var location: String = ""
    var start: Date = DateTimeUtil.shared.nextSaturday(at: 14, timeZone: TimeZone(identifier: "Europe/Zurich")!)
    var end: Date = DateTimeUtil.shared.nextSaturday(at: 16, timeZone: TimeZone(identifier: "Europe/Zurich")!)
    var sendPushNotification: Bool = true
    var showConfirmationDialog: Bool = false
    var showPreviewSheet: Bool = false
    var showTemplatesSheet: Bool = false
    var templatesState: UiState<[AktivitaetTemplate]> = .loading(subState: .idle)
    var description: String = "" {
        didSet {
            trimmedDescription = description.htmlTrimmed
        }
    }
    
    @ObservationIgnored
    private var trimmedDescription = ""
    
    private let selectedSheetMode: AktivitaetBearbeitenMode
    private let service: StufenbereichService
    private let stufe: SeesturmStufe
    
    init(
        selectedSheetMode: AktivitaetBearbeitenMode,
        service: StufenbereichService,
        stufe: SeesturmStufe
    ) {
        self.selectedSheetMode = selectedSheetMode
        self.service = service
        self.stufe = stufe
        self.title = stufe.aktivitaetDescription
        
        switch selectedSheetMode {
        case .insert:
            self.aktivitaetState = .success(data: ())
        case .update(_):
            self.aktivitaetState = .loading(subState: .idle)
        }
    }
    
    var previewSheetBinding: Binding<Bool> {
        Binding(
            get: { self.showPreviewSheet && self.aktivitaetForPreview != nil },
            set: { isShown in
                withAnimation {
                    self.showPreviewSheet = isShown
                }
            }
        )
    }
    var aktivitaetForPublishing: CloudFunctionEventPayload {
        return CloudFunctionEventPayload(
            summary: self.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: self.description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: self.location.trimmingCharacters(in: .whitespacesAndNewlines),
            start: self.start,
            end: self.end
        )
    }
    var aktivitaetForPreview: GoogleCalendarEvent? {
        try? aktivitaetForPublishing.toGoogleCalendarEvent()
    }
    private var publishingValidationStatus: AktivitaetValidationStatus {
        
        let aktivitaet = aktivitaetForPublishing
        
        // errors
        if aktivitaet.end < aktivitaet.start {
            return .error(message: "Das Enddatum darf nicht vor dem Startdatum sein.")
        }
        if aktivitaet.summary.isEmpty {
            return .error(message: "Der Titel darf nicht leer sein.")
        }
        
        // warnings
        if abs(Calendar.current.dateComponents([.hour], from: aktivitaet.start, to: aktivitaet.end).hour ?? 2) < 2 {
            return .warning(message: "Die Aktivität ist kürzer als 2 Stunden. Möchtest du die Aktivität trotzdem \(selectedSheetMode.verb)?")
        }
        if aktivitaet.start < Date.now {
            return .warning(message: "Das Startdatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(selectedSheetMode.verb)?")
        }
        if aktivitaet.end < Date.now {
            return .warning(message: "Das Enddatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(selectedSheetMode.verb)?")
        }
        if trimmedDescription.isEmpty {
            return .warning(message: "Die Beschreibung ist leer. Möchtest du die Aktivität trotzdem \(selectedSheetMode.verb)?")
        }
        if aktivitaet.location.isEmpty {
            return .warning(message: "Der Treffpunkt ist leer. Möchtest du die Aktivität trotzdem \(selectedSheetMode.verb)?")
        }
        
        return .valid
    }
    
    var confirmationDialogTitle: String {
        switch self.publishingValidationStatus {
        case .valid:
            return "Die Aktivität wird \(sendPushNotification ? "mit" : "ohne") Push-Nachricht \(selectedSheetMode.verbPassiv)."
        case .warning(let message):
            return message
        case .error(let message):
            return message
        }
    }
    var confirmationDialogConfirmButtonText: String {
        switch self.publishingValidationStatus {
        case .valid:
            return selectedSheetMode.buttonTitle
        case .warning(_), .error(_):
            return "Trotzdem \(selectedSheetMode.verb)"
        }
    }
    
    func fetchAktivitaetIfNecessary() async {
        
        if case .update(let eventId) = selectedSheetMode, self.aktivitaetState.taskShouldRun {
            
            withAnimation {
                aktivitaetState = .loading(subState: .loading)
            }
            
            let result = await service.fetchEvent(stufe: stufe, eventId: eventId)
            
            switch result {
            case .error(let e):
                withAnimation {
                    aktivitaetState = .error(message: "Aktivität konnte nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    title = d.title
                    description = d.description ?? ""
                    location = d.location ?? ""
                    start = d.start
                    end = d.end
                    aktivitaetState = .success(data: ())
                }
            }
        }
    }
    
    func trySubmit() {
        
        switch self.publishingValidationStatus{
        case .error(let message):
            withAnimation {
                publishAktivitaetState = .error(action: (), message: message)
            }
        case .warning(_), .valid:
            withAnimation {
                showConfirmationDialog = true
            }
        }
    }
    
    func submit() async {
        
        withAnimation {
            publishAktivitaetState = .loading(action: ())
        }
        
        switch selectedSheetMode {
        case .insert:
            await addAktivitaet()
        case .update(let eventId):
            await updateAktivitaet(eventId: eventId)
        }
    }
    
    private func addAktivitaet() async {
        
        let result = await service.addNewAktivitaet(event: aktivitaetForPublishing, stufe: stufe, withNotification: sendPushNotification)
        
        switch result {
        case .error(let error):
            let message: String
            if sendPushNotification {
                message = "Beim Veröffentlichen der Aktivität oder beim Senden der Push-Nachricht ist ein Fehler aufgetreten. \(error.defaultMessage)"
            } else {
                message = "Beim Veröffentlichen der Aktivität ist ein Fehler aufgetreten. \(error.defaultMessage)"
            }
            withAnimation {
                publishAktivitaetState = .error(action: (), message: message)
            }
        case .success(_):
            let message: String
            if sendPushNotification {
                message = "Aktivität erfolgreich veröffentlicht. Push-Nachricht gesendet."
            }
            else {
                message = "Aktivität erfolgreich veröffentlicht."
            }
            withAnimation {
                publishAktivitaetState = .success(action: (), message: message)
            }
        }
    }
    
    private func updateAktivitaet(eventId: String) async {
        
        let result = await service.updateExistingAktivitaet(eventId: eventId, event: aktivitaetForPublishing, stufe: stufe, withNotification: sendPushNotification)
        
        switch result {
        case .error(let error):
            let message: String
            if sendPushNotification {
                message = "Beim Aktualisieren der Aktivität oder beim Senden der Push-Nachricht ist ein Fehler aufgetreten. \(error.defaultMessage)"
            }
            else {
                message = "Beim Aktualisieren der Aktivität ist ein Fehler aufgetreten. \(error.defaultMessage)"
            }
            withAnimation {
                publishAktivitaetState = .error(action: (), message: message)
            }
        case .success(_):
            let message: String
            if sendPushNotification {
                message = "Aktivität erfolgreich aktualisiert. Push-Nachricht gesendet."
            }
            else {
                message = "Aktivität erfolgreich aktualisiert."
            }
            withAnimation {
                publishAktivitaetState = .success(action: (), message: message)
            }
        }
    }
    
    func observeTemplates() async {
        
        withAnimation {
            templatesState = .loading(subState: .loading)
        }
        
        for await result in service.observeAktivitaetTemplates(stufe: stufe) {
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
    
    func useTemplate(_ template: AktivitaetTemplate) {
        withAnimation {
            showTemplatesSheet = false
            description = template.description
        }
    }
}
