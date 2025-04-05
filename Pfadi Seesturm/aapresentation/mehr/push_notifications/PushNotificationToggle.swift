//
//  AsyncPicker.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import SwiftUI

struct PushNotificationToggle: View {
    
    let topic: SeesturmFCMNotificationTopic
    let state: ActionState<SeesturmFCMNotificationTopic>
    let isOn: Bool
    let onToggle: (Bool) async -> Void
    
    var body: some View {
        if isPushNotificationToggleLoading {
            HStack(alignment: .center, spacing: 16) {
                Text(topic.topicName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        else {
            Toggle(
                topic.topicName,
                isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        Task {
                            await onToggle(newValue)
                        }
                    }
                )
            )
            .disabled(state.isLoading)
            .tint(Color.SEESTURM_GREEN)
        }
    }
}

extension PushNotificationToggle {
    var isPushNotificationToggleLoading: Bool {
        switch self.state {
        case .loading(let action):
            return action == self.topic
        default:
            return false
        }
    }
}

#Preview {
    let state1: ActionState<SeesturmFCMNotificationTopic> = .loading(action: .aktuell)
    List {
        PushNotificationToggle(
            topic: .aktuell,
            state: state1,
            isOn: true,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .biberAktivitäten,
            state: state1,
            isOn: false,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .pioAktivitäten,
            state: state1,
            isOn: false,
            onToggle: { _ in }
        )
    }
    let state2: ActionState<SeesturmFCMNotificationTopic> = .success(action: .aktuell, message: "")
    List {
        PushNotificationToggle(
            topic: .aktuell,
            state: state2,
            isOn: true,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .biberAktivitäten,
            state: state2,
            isOn: false,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .pioAktivitäten,
            state: state2,
            isOn: false,
            onToggle: { _ in }
        )
    }
    let state3: ActionState<SeesturmFCMNotificationTopic> = .idle
    List {
        PushNotificationToggle(
            topic: .aktuell,
            state: state3,
            isOn: true,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .biberAktivitäten,
            state: state3,
            isOn: false,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .pioAktivitäten,
            state: state3,
            isOn: false,
            onToggle: { _ in }
        )
    }
}
