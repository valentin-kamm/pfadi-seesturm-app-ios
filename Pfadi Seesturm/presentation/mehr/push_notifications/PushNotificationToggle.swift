//
//  PushNotificationToggle.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//
import SwiftUI

struct PushNotificationToggle: View {
    
    private let topic: SeesturmFCMNotificationTopic
    private let state: ActionState<SeesturmFCMNotificationTopic>
    private let isOn: Bool
    private let onToggle: (Bool) -> Void
    
    init(
        topic: SeesturmFCMNotificationTopic,
        state: ActionState<SeesturmFCMNotificationTopic>,
        isOn: Bool,
        onToggle: @escaping (Bool) -> Void
    ) {
        self.topic = topic
        self.state = state
        self.isOn = isOn
        self.onToggle = onToggle
    }
    
    private var isPushNotificationToggleLoading: Bool {
        switch self.state {
        case .loading(let action):
            return action.id == self.topic.id
        default:
            return false
        }
    }
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 16) {
            
            Text(topic.topicName)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .opacity(isPushNotificationToggleLoading ? 1 : 0)
            Toggle(
                isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        onToggle(newValue)
                    }
                ),
                label: {}
            )
            .disabled(state.isLoading)
            .tint(Color.SEESTURM_GREEN)
        }
    }
}

#Preview {
    List {
        PushNotificationToggle(
            topic: .biberAktivitaeten,
            state: .loading(action: .wolfAktivitaeten),
            isOn: true,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .wolfAktivitaeten,
            state: .loading(action: .wolfAktivitaeten),
            isOn: true,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .pfadiAktivitaeten,
            state: .loading(action: .wolfAktivitaeten),
            isOn: false,
            onToggle: { _ in }
        )
        PushNotificationToggle(
            topic: .pioAktivitaeten,
            state: .loading(action: .wolfAktivitaeten),
            isOn: true,
            onToggle: { _ in }
        )
    }
}
