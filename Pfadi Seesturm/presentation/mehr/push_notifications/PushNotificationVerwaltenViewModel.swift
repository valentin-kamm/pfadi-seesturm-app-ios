//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import SwiftUI
import SwiftData

@Observable
@MainActor
class PushNotificationVerwaltenViewModel {
    
    var actionState: ActionState<SeesturmFCMNotificationTopic> = .idle
    var showSettingsAlert: Bool = false
    
    private let service: FCMService
    
    init(
        service: FCMService
    ) {
        self.service = service
    }
    
    func toggleTopic(topic: SeesturmFCMNotificationTopic, isSwitchingOn: Bool) async {
        
        withAnimation {
            actionState = .loading(action: topic)
        }
        if isSwitchingOn {
            await subscribe(to: topic)
        }
        else {
            await unsubscribe(from: topic)
        }
    }
    
    private func subscribe(to topic: SeesturmFCMNotificationTopic) async {
        
        let result = await service.subscribe(to: topic)
        
        switch result {
        case .error(let e):
            switch e {
            case .permissionError:
                withAnimation {
                    showSettingsAlert = true
                    actionState = .idle
                }
            default:
                withAnimation {
                    actionState = .error(action: topic, message: e.defaultMessage)
                }
            }
        case .success(_):
            withAnimation {
                actionState = .success(action: topic, message: "Anmeldung für \(topic.topicName) erfolgreich.")
            }
        }
    }
    
    private func unsubscribe(from topic: SeesturmFCMNotificationTopic) async {
        
        let result = await service.unsubscribe(from: topic)
        
        switch result {
        case .error(let e):
            withAnimation {
                actionState = .error(action: topic, message: e.defaultMessage)
            }
        case .success(_):
            withAnimation {
                actionState = .success(action: topic, message: "Abmeldung von \(topic.topicName) erfolgreich.")
            }
        }
    }
    
    func goToAppSettings() {
        service.goToAppSettings()
    }
}
