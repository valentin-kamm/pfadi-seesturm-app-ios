//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import SwiftUI
import SwiftData

class PushNotificationVerwaltenViewModel: StateManager<PushNotificationVerwaltenState> {
    
    private let service: FCMSubscriptionService
    private let modelContext: ModelContext
    init(
        service: FCMSubscriptionService,
        modelContext: ModelContext
    ) {
        self.service = service
        self.modelContext = modelContext
        super.init(initialState: PushNotificationVerwaltenState())
    }
    
    var settingsAlertBinding: Binding<Bool> {
        Binding(
            get: {
                self.state.showSettingsAlert
            },
            set: { newValue in
                self.updateAlertVisibility(newVisibility: newValue)
            }
        )
    }
    var actionStateBinding: Binding<ActionState<SeesturmFCMNotificationTopic>> {
        Binding(
            get: { self.state.actionState },
            set: { newValue in
                self.updateState { state in
                    state.actionState = newValue
                }
            }
        )
    }
    
    func toggleTopic(topic: SeesturmFCMNotificationTopic, isSwitchingOn: Bool) async {
        updateState { oldState in
            oldState.actionState = .loading(action: topic)
        }
        if isSwitchingOn {
            await subscribe(topic: topic)
        }
        else {
            await unsubscribe(topic: topic)
        }
    }
    private func subscribe(topic: SeesturmFCMNotificationTopic) async {
        let result = await service.subscribe(to: topic)
        switch result {
        case .error(let e):
            switch e {
            case .permissionError:
                updateAlertVisibility(newVisibility: true)
                updateState { oldState in
                    oldState.actionState = .idle
                }
            default:
                updateState { oldState in
                    oldState.actionState = .error(action: topic, message: e.defaultMessage)
                }
            }
        case .success(_):
            let localSaveResult = storeLocalTopic(topic: topic)
            switch localSaveResult {
            case .idle, .loading(_):
                print("Anmeldung in progress")
            case .error(let action, let message):
                updateState { oldState in
                    oldState.actionState = .error(action: topic, message: message)
                }
            case .success(let action, let message):
                updateState { oldState in
                    oldState.actionState = .success(action: topic, message: message)
                }
            }
        }
    }
    private func unsubscribe(topic: SeesturmFCMNotificationTopic) async {
        let result = await service.unsubscribe(from: topic)
        switch result {
        case .error(let e):
            updateState { oldState in
                oldState.actionState = .error(action: topic, message: e.defaultMessage)
            }
        case .success(_):
            let localDeleteResult = deleteLocalTopic(topic: topic)
            switch localDeleteResult {
            case .idle, .loading(_):
                print("Abmeldung in progress")
            case .error(let action, let message):
                updateState { oldState in
                    oldState.actionState = .error(action: topic, message: message)
                }
            case .success(let action, let message):
                updateState { oldState in
                    oldState.actionState = .success(action: topic, message: message)
                }
            }
        }
    }
    
    private func storeLocalTopic(topic: SeesturmFCMNotificationTopic) -> ActionState<SeesturmFCMNotificationTopic> {
        do {
            modelContext.insert(
                SubscribedFCMNotificationTopicDao(topic: topic)
            )
            try modelContext.save()
            return .success(action: topic, message: "Anmeldung für \(topic.topicName) erfolgreich.")
        }
        catch {
            return .error(action: topic, message: "Anmeldung für \(topic.topicName) erfolgreich. Beim Speichern auf dem Gerät ist ein Fehler aufgetreten.")
        }
    }
    private func deleteLocalTopic(topic: SeesturmFCMNotificationTopic) -> ActionState<SeesturmFCMNotificationTopic> {
        do {
            let descriptor = FetchDescriptor<SubscribedFCMNotificationTopicDao>(
                predicate: SubscribedFCMNotificationTopicDao.topicFilter(topic: topic)
            )
            let daoToDelete = try modelContext.fetch(descriptor)
            if !daoToDelete.isEmpty {
                for dao in daoToDelete {
                    modelContext.delete(dao)
                }
                try modelContext.save()
            }
            return .success(action: topic, message: "Abmeldung von \(topic.topicName) erfolgreich.")
        }
        catch {
            return .error(action: topic, message: "Abmeldung von \(topic.topicName) erfolgreich. Beim Speichern auf dem Gerät ist ein Fehler aufgetreten.")
        }
    }
    
    private func updateAlertVisibility(newVisibility: Bool) {
        self.updateState { oldState in
            oldState.showSettingsAlert = newVisibility
        }
    }
}
