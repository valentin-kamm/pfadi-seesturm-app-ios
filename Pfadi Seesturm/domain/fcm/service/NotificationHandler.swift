//
//  NotificationHandler.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 12.04.2025.
//
import FirebaseMessaging
import Foundation

final class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    private let appState: AppStateViewModel
    private let authService: AuthService
    private let schoepflialarmService: SchoepflialarmService
    private let fcmService: FCMService
    
    init(
        appState: AppStateViewModel,
        authService: AuthService,
        schoepflialarmService: SchoepflialarmService,
        fcmService: FCMService
    ) {
        self.appState = appState
        self.authService = authService
        self.schoepflialarmService = schoepflialarmService
        self.fcmService = fcmService
        
        super.init()
        setUpNotifications()
    }
    
    private func setUpNotifications() {
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        // notification actions for schöpflialarm
        var actions: [UNNotificationAction] = []
        for reaction in SchoepflialarmReactionType.allCases {
            let action = UNNotificationAction(
                identifier: reaction.id,
                title: reaction.title,
                options: []
            )
            actions.append(action)
        }
        let schöpflialarmNotificationCategory = UNNotificationCategory(
            identifier: SeesturmFCMNotificationTopic.schoepflialarm.rawValue,
            actions: actions,
            intentIdentifiers: [],
            options: .customDismissAction
        )
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([schöpflialarmNotificationCategory])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        if let newToken = fcmToken, let uid = authService.getCurrentUid() {
            Task {
                
                let isHitobitoUser = await authService.isCurrentUserHitobitoUser()
                if !isHitobitoUser {
                    return
                }
                
                let result = await fcmService.updateFCMToken(for: uid, newToken: newToken)
                switch result {
                case .error(let e):
                    print("New FCM Token could not be saved to firestore. \(e.defaultMessage)")
                case .success(_):
                    break
                }
            }
        }
    }
    
    // presenting notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        Task {
            let presentationOptions = await handleIncomingNotification(notification: notification)
            completionHandler(presentationOptions)
        }
    }
    
    // reacting to notification clicks
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            self.handleNotificationTap(response: response)
            completionHandler()
        }
    }
    
    @MainActor
    private func handleNotificationTap(response: UNNotificationResponse) {
        
        guard let notificationData = try? decodeNotificationContents(data: response.notification.request.content.userInfo) else {
            return
        }
        guard let topic = try? SeesturmFCMNotificationTopic(topicString: notificationData.topic) else {
            return
        }
        
        switch response.actionIdentifier {
        case SchoepflialarmReactionType.alreadyThere.rawValue, SchoepflialarmReactionType.notComing.rawValue, SchoepflialarmReactionType.coming.rawValue:
            guard let reaction = SchoepflialarmReactionType(rawValue: response.actionIdentifier) else {
                return
            }
            Task {
                let authResult = await authService.reauthenticateWithHitobito(resubscribeToSchoepflialarm: false)
                switch authResult {
                case .error(_):
                    return
                case .success(let user):
                    let _ = await schoepflialarmService.sendSchoepflialarmReaction(user: user, reaction: reaction, runInParallel: true)
                }
            }
        case UNNotificationDefaultActionIdentifier:
            guard let (tab, path) = topic.navigationDestination(customKey: notificationData.customKey) else {
                return
            }
            appState.setNavigationPath(tab: tab, path: path)
            appState.changeTab(newTab: tab)
        default:
            return
        }
    }
    
    private func handleIncomingNotification(notification: UNNotification) async -> UNNotificationPresentationOptions {
        
        do {
            
            let notificationData = try decodeNotificationContents(data: notification.request.content.userInfo)
            let topic = try SeesturmFCMNotificationTopic(topicString: notificationData.topic)
            
            if !topic.displayForAuthenticatedHitobitoUserOnly {
                return [.badge, .banner, .sound, .list]
            }
            
            let isHitobitoUser = await authService.isCurrentUserHitobitoUser()
            if !isHitobitoUser {
                return []
            }
            
            return [.badge, .banner, .sound, .list]
        }
        catch {
            return []
        }
    }
    
    private func decodeNotificationContents(data: [AnyHashable : Any]) throws -> CloudFunctionPushNotificationRequestDto {
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        return try JSONDecoder().decode(CloudFunctionPushNotificationRequestDto.self, from: jsonData)
    }
}
