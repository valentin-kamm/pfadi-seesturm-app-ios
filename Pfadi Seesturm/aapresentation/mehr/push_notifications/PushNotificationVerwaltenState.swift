//
//  PushNotificationVerwaltenState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.02.2025.
//

struct PushNotificationVerwaltenState {
    var actionState: ActionState<SeesturmFCMNotificationTopic> = .idle
    var showSettingsAlert: Bool = false
}
