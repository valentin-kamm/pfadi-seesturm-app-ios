//
//  AktivitätBearbeitenViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI
import FirebaseFunctions

class AktivitaetBearbeitenViewModel: StateManager<AktivitaetBearbeitenState> {
    
    private let selectedSheetMode: StufenbereichSheetMode
    private let service: StufenbereichService
    private let stufe: SeesturmStufe
    private let onPublishAktivitaetStateChange: (ActionState<Void>) -> Void
    private let onDismiss: () -> Void
    
    init(
        selectedSheetMode: StufenbereichSheetMode,
        service: StufenbereichService,
        stufe: SeesturmStufe,
        onPublishAktivitaetStateChange: @escaping (ActionState<Void>) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.selectedSheetMode = selectedSheetMode
        self.service = service
        self.stufe = stufe
        self.onPublishAktivitaetStateChange = onPublishAktivitaetStateChange
        self.onDismiss = onDismiss
        super.init(initialState: AktivitaetBearbeitenState(selectedSheetMode: selectedSheetMode))
    }
        
    var aktivitaetForPublishing: CloudFunctionEventPayload {
        return CloudFunctionEventPayload(
            summary: self.state.title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: self.state.description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: self.state.location.trimmingCharacters(in: .whitespacesAndNewlines),
            isAllDay: false,
            start: self.state.start,
            end: self.state.end
        )
    }
    var publishingValidationStatus: AktivitaetValidationStatus {
        
        let aktivitaet = aktivitaetForPublishing
        let verb = selectedSheetMode == .insert || selectedSheetMode == .hidden ? "veröffentlichen" : "aktualisieren"
        
        // errors
        if aktivitaet.end < aktivitaet.start {
            return .error(message: "Das Enddatum darf nicht vor dem Startdatum sein.")
        }
        if aktivitaet.summary.isEmpty {
            return .error(message: "Der Titel darf nicht leer sein.")
        }
        
        // warnings
        //let components = calendar.dateComponents([.hour], from: startDate, to: endDate)
        if abs(Calendar.current.dateComponents([.hour], from: aktivitaet.start, to: aktivitaet.end).hour ?? 2) < 2 {
            return .warning(message: "Die Aktivität ist kürzer als 2 Stunden. Möchtest du die Aktivität trotzdem \(verb)?")
        }
        if aktivitaet.start < Date.now {
            return .warning(message: "Das Startdatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(verb)?")
        }
        if aktivitaet.end < Date.now {
            return .warning(message: "Das Enddatum ist in der Vergangenheit. Möchtest du die Aktivität trotzdem \(verb)?")
        }
        if aktivitaet.description.isEmpty {
            return .warning(message: "Die Beschreibung ist leer. Möchtest du die Aktivität trotzdem \(verb)?")
        }
        if aktivitaet.location.isEmpty {
            return .warning(message: "Der Treffpunkt ist leer. Möchtest du die Aktivität trotzdem \(verb)?")
        }
        
        return .valid
    }
    var aktivitaetForPreview: GoogleCalendarEvent? {
        try? aktivitaetForPublishing.toGoogleCalendarEvent()
    }
    
    var navigationTitle: String {
        switch selectedSheetMode {
        case .hidden, .insert:
            "Neue \(stufe.aktivitaetDescription)"
        case .update(_):
            "\(stufe.aktivitaetDescription) bearbeiten"
        }
    }
    var buttonTitle: String {
        switch selectedSheetMode {
        case .hidden, .insert:
            "Veröffentlichen"
        case .update(_):
            "Aktualisieren"
        }
    }
    var confirmationDialogTitle: String {
        switch self.publishingValidationStatus {
        case .valid:
            let firstPart = "Die Aktivität wird \(state.sendPushNotification ? "mit" : "ohne") Push-Nachricht "
            switch self.selectedSheetMode {
            case .hidden, .insert:
                return firstPart + "veröffentlicht."
            case .update(_):
                return firstPart + "aktualisiert."
            }
        case .warning(let message):
            return message
        case .error(let message):
            return message
        }
    }
    var confirmationDialogConfirmButtonText: String {
        switch self.publishingValidationStatus {
        case .valid:
            switch self.selectedSheetMode {
            case .hidden, .insert:
                return "Veröffentlichen"
            case .update(_):
                return "Aktualisieren"
            }
        case .warning(_), .error(_):
            switch self.selectedSheetMode {
            case .hidden, .insert:
                return "Trotzdem veröffentlichen"
            case .update(_):
                return "Trotzdem aktualisieren"
            }
        }
    }
    
    var showConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showConfirmationDialog },
            set: { isShown in
                self.updateState { state in
                    state.showConfirmationDialog = isShown
                }
            }
        )
    }
    var publishAktivitaetStateBinding: Binding<ActionState<Void>> {
        Binding(
            get: { self.state.publishAktivitaetState },
            set: { newValue in
                self.changePublishAktivitaetState(newState: newValue)
            }
        )
    }
    var sendPushNotificationBinding: Binding<Bool> {
        Binding(
            get: { self.state.sendPushNotification },
            set: { newValue in
                self.updateState { state in
                    state.sendPushNotification = newValue
                }
            }
        )
    }
    var titleBinding: Binding<String> {
        Binding(
            get: { self.state.title },
            set: { newValue in
                self.updateTitle(title: newValue)
            }
        )
    }
    var descriptionBinding: Binding<String> {
        Binding(
            get: { self.state.description },
            set: { newValue in
                self.updateDescription(description: newValue)
            }
        )
    }
    var locationBinding: Binding<String> {
        Binding(
            get: { self.state.location },
            set: { newValue in
                self.updateLocation(location: newValue)
            }
        )
    }
    var startBinding: Binding<Date> {
        Binding(
            get: { self.state.start },
            set: { newValue in
                self.updateStartDate(date: newValue)
            }
        )
    }
    var endBinding: Binding<Date> {
        Binding(
            get: { self.state.end },
            set: { newValue in
                self.updateEndDate(date: newValue)
            }
        )
    }
    
    func fetchAktivitaetIfNecessary() async {
        
        switch selectedSheetMode {
        case .hidden, .insert:
            return
        case .update(let eventId):
            
            guard self.state.aktivitaetState.taskShouldRun else {
                return
            }
            
            updateState { state in
                state.aktivitaetState = .loading(subState: .loading)
            }
            
            let result = await service.fetchEvent(stufe: stufe, eventId: eventId)
            
            switch result {
            case .error(let e):
                updateState { state in
                    state.aktivitaetState = .error(message: "Aktivität konnte nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                updateState { state in
                    state.title = d.title
                    state.description = d.description ?? ""
                    state.location = d.location ?? ""
                    state.start = d.startDate
                    state.end = d.endDate
                    state.aktivitaetState = .success(data: ())
                }
            }
        }
    }
    
    func trySubmit() {
        
        switch self.publishingValidationStatus {
        case .error(let message):
            changePublishAktivitaetState(newState: .error(action: (), message: message))
            return
        case .warning(_), .valid:
            updateConfirmationDialogVisibility(isVisible: true)
            return
        }
    }
    
    func submit() async {
        
        changePublishAktivitaetState(newState: .loading(action: ()))
        
        switch selectedSheetMode {
        case .hidden, .insert:
            await addNewAktivitaet()
        case .update(let eventId):
            await updateExistingAktivitaet(eventId: eventId)
        }
    }
    
    private func addNewAktivitaet() async {
        
        let withNotification = state.sendPushNotification
        let result = await service.addNewAktivitaet(event: aktivitaetForPublishing, stufe: stufe, withNotification: withNotification)
        
        switch result {
        case .error(let error):
            if withNotification {
                changePublishAktivitaetState(newState: .error(action: (), message: "Beim Veröffentlichen oder Senden der Push-Nachricht ist ein Fehler aufgetreten. \(error.defaultMessage)"))
            }
            else {
                changePublishAktivitaetState(newState: .error(action: (), message: "Beim Veröffentlichen der Aktivität ist ein Fehler aufgetreten. \(error.defaultMessage)"))
            }
        case .success(_):
            if withNotification {
                changePublishAktivitaetState(newState: .success(action: (), message: "Aktivität erfolgreich veröffentlicht. Push-Nachricht versendet."))
            }
            else {
                changePublishAktivitaetState(newState: .success(action: (), message: "Aktivität erfolgreich veröffentlicht."))
            }
            onDismiss()
        }
    }
    
    private func updateExistingAktivitaet(eventId: String) async {
        
        let withNotification = state.sendPushNotification
        let result = await service.updateExistingAktivitaet(eventId: eventId, event: aktivitaetForPublishing, stufe: stufe, withNotification: withNotification)
        
        switch result {
        case .error(let error):
            if withNotification {
                changePublishAktivitaetState(newState: .error(action: (), message: "Beim Aktualisieren oder Senden der Push-Nachricht ist ein Fehler aufgetreten. \(error.defaultMessage)"))
            }
            else {
                changePublishAktivitaetState(newState: .error(action: (), message: "Beim Aktualisieren der Aktivität ist ein Fehler aufgetreten. \(error.defaultMessage)"))
            }
        case .success(_):
            if withNotification {
                changePublishAktivitaetState(newState: .success(action: (), message: "Aktivität erfolgreich aktualisiert. Push-Nachricht versendet."))
            }
            else {
                changePublishAktivitaetState(newState: .success(action: (), message: "Aktivität erfolgreich aktualisiert."))
            }
            onDismiss()
        }
    }
    
    private func changePublishAktivitaetState(newState: ActionState<Void>) {
        updateState { state in
            state.publishAktivitaetState = newState
        }
        onPublishAktivitaetStateChange(newState)
    }
    
    func updateTitle(title: String) {
        updateState { state in
            state.title = title
        }
    }
    func updateDescription(description: String) {
        updateState { state in
            state.description = description
        }
    }
    func updateLocation(location: String) {
        updateState { state in
            state.location = location
        }
    }
    func updateStartDate(date: Date) {
        updateState { state in
            state.start = date
        }
    }
    func updateEndDate(date: Date) {
        updateState { state in
            state.end = date
        }
    }
    
    func updateConfirmationDialogVisibility(isVisible: Bool) {
        updateState { state in
            state.showConfirmationDialog = isVisible
        }
    }
}

enum AktivitaetValidationStatus {
    case valid
    case warning(message: String)
    case error(message: String)
}

/*

// function to update existing event
func updateEvent(eventId: String) async {
    updateEventContinuation = nil
    withAnimation {
        updateEventAlert = true
    }
    do {
        try await withCheckedThrowingContinuation { continuation in
            self.updateEventContinuation = continuation
        }
    }
    catch {
        withAnimation {
            updateEventLoadingState = .none
        }
        return
    }
    updateEventLoadingState = .loading
    do {
        let payload = try constructUpdateEventPayload(eventId: eventId)
        let jsonData = try JSONEncoder().encode(payload)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        let _ = try await CloudFunctionsManager.shared.callFirebaseCloudFunction(function: .updateEvent, payload: jsonObject)
        try await sendPushNotificationIfNeeded()
        let successMessage = "Aktivität erfolgreich aktualisiert." + (sendPushNotification ? " Push-Nachricht wurde versendet" : "")
        withAnimation {
            updateEventLoadingState = .result(.success(successMessage))
        }
    }
    catch let pfadiSeesturmError as PfadiSeesturmAppError {
        withAnimation {
            updateEventLoadingState = .result(.failure(pfadiSeesturmError))
        }
    }
    catch {
        let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
        withAnimation {
            updateEventLoadingState = .result(.failure(pfadiSeesturmError))
        }
    }
}

// function to publish new activity to google calendar
func publishNewEvent() async {
    publishEventContinuation = nil
    withAnimation {
        publishEventAlert = true
    }
    do {
        try await withCheckedThrowingContinuation { continuation in
            self.publishEventContinuation = continuation
        }
    }
    catch {
        withAnimation {
            publishEventLoadingState = .none
        }
        return
    }
    publishEventLoadingState = .loading
    do {
        let payload = try constructAddNewEventPayload()
        let jsonData = try JSONEncoder().encode(payload)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        let _ = try await CloudFunctionsManager.shared.callFirebaseCloudFunction(function: .addEvent, payload: jsonObject)
        try await sendPushNotificationIfNeeded()
        let successMessage = "Aktivität erfolgreich veröffentlicht." + (sendPushNotification ? " Push-Nachricht wurde versendet" : "")
        withAnimation {
            publishEventLoadingState = .result(.success(successMessage))
        }
    }
    catch let pfadiSeesturmError as PfadiSeesturmAppError {
        withAnimation {
            publishEventLoadingState = .result(.failure(pfadiSeesturmError))
        }
    }
    catch {
        let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
        withAnimation {
            publishEventLoadingState = .result(.failure(pfadiSeesturmError))
        }
    }
}

// helper functions for publishing / updating events
private func sendPushNotificationIfNeeded() async throws {
    /*
    if !sendPushNotification {
        return
    }
    let notificationPayload = FCMManager.shared.constructPushNotificationPayload(topic: SeesturmNotificationTopic(stufe: stufe))
    try await FCMManager.shared.sendPushNotification(payload: notificationPayload)
     */
}
private func constructAddNewEventPayload() throws -> FCFAddEventRequest {
    return FCFAddEventRequest(
        calendarId: "X",//stufe.calendar.info.calendarId,
        payload: try constructEventPayload()
    )
}
private func constructUpdateEventPayload(eventId: String) throws -> FCFUpdateEventRequest {
    return FCFUpdateEventRequest(
        calendarId: "x",//stufe.calendar.info.calendarId,
        eventId: eventId,
        payload: try constructEventPayload()
    )
}
private func constructEventPayload() throws -> CalendarEventPayload {
    return CalendarEventPayload(
        start: CalendarEventPayload.CalendarEventDateTimePayload(
            dateTime: try DateTimeUtil.shared.getIso8601DateString(date: editData.startDateTime, timeZone: TimeZone(identifier: "Europe/Zurich"))
        ),
        end: CalendarEventPayload.CalendarEventDateTimePayload(
            dateTime: try DateTimeUtil.shared.getIso8601DateString(date: editData.endDateTime, timeZone: TimeZone(identifier: "Europe/Zurich"))
        ),
        summary: editData.title,
        location: editData.treffpunkt.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : editData.treffpunkt.trimmingCharacters(in: .whitespacesAndNewlines),
        description: editData.html.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? nil : editData.html.trimmingCharacters(in: .whitespacesAndNewlines)
    )
}
 */
