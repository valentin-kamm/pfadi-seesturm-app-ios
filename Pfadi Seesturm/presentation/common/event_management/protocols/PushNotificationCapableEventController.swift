//
//  PushNotificationCapableEventController.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.01.2026.
//

@MainActor
protocol PushNotificationCapableEventController: AnyObject {
    
    var sendPushNotification: Bool { get set }
}
