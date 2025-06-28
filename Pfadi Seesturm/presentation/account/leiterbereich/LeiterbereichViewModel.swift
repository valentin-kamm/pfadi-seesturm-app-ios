//
//  LeiterbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class LeiterbereichViewModel {
    
    // loading data
    var termineState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var usersState: UiState<[FirebaseHitobitoUser]> = .loading(subState: .idle)
    
    // account interactions
    var showSignOutConfirmationDialog: Bool = false
    var showDeleteAccountConfirmationDialog: Bool = false
    
    // food
    var ordersStateDto: UiState<[FoodOrderDto]> = .loading(subState: .idle)
    var showInsertFoodSheet: Bool = false
    var addNewOrderState: ActionState<Void> = .idle
    var showDeleteAllOrdersDialog: Bool = false
    var deleteAllOrdersState: ActionState<Void> = .idle
    var modifyOrderErrorMessage: String? = nil
    var newFoodItemDescription: String = ""
    var newFoodItemCount: Int = 1
    
    // schöpflialarm
    var schoepflialarmResultDto: UiState<SchoepflialarmDto> = .loading(subState: .idle)
    var schoepflialarmReactionsResultDto: UiState<[SchoepflialarmReactionDto]> = .loading(subState: .idle)
    var sendSchoepflialarmState: ActionState<Void> = .idle
    var sendSchoepflialarmReactionState: ActionState<SchoepflialarmReactionType> = .idle
    var toggleSchoepflialarmReactionsPushNotificationState: ActionState<SeesturmFCMNotificationTopic> = .idle
    var showNotificationSettingsAlert: Bool = false
    var showLocationSettingsAlert: Bool = false
    var showConfirmSchoepflialarmAlert: Bool = false
    var showSchoepflialarmSheet: Bool = false
    var schoepflialarmMessage: String = ""
    
    private let leiterbereichService: LeiterbereichService
    private let schoepflialarmService: SchoepflialarmService
    private let fcmService: FCMService
    private let user: FirebaseHitobitoUser
    private let calendar: SeesturmCalendar
    
    init(
        leiterbereichService: LeiterbereichService,
        schoepflialarmService: SchoepflialarmService,
        fcmService: FCMService,
        user: FirebaseHitobitoUser,
        calendar: SeesturmCalendar
    ) {
        self.leiterbereichService = leiterbereichService
        self.schoepflialarmService = schoepflialarmService
        self.fcmService = fcmService
        self.user = user
        self.calendar = calendar
    }
    
    func loadData() async {
        
        var tasks: [() async -> Void] = []
        
        if termineState.taskShouldRun {
            tasks.append {
                await self.fetchNext3Events()
            }
        }
        tasks.append {
            await self.loadFoodData()
        }
        tasks.append {
            await self.observeSchoepflialarm()
        }
        tasks.append {
            await self.observeSchoepflialarmReactions()
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    func fetchNext3Events() async {
        withAnimation {
            termineState = .loading(subState: .loading)
        }
        let result = await leiterbereichService.fetchNext3Events(calendar: calendar)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    termineState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    termineState = .error(message: "Die nächsten Termine konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                termineState = .success(data: d)
            }
        }
    }
    
    private func observeUsers() async {
        withAnimation {
            usersState = .loading(subState: .loading)
        }
        for await result in leiterbereichService.observeUsers() {
            switch result {
            case .error(let e):
                withAnimation {
                    usersState = .error(message: "Benutzer konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    usersState = .success(data: d)
                }
            }
        }
    }
    
    func goToAppSettings() {
        schoepflialarmService.goToAppSettings()
    }
    
    func requestNotificationPermissionIfNecessary() async {
        let _ = try? await fcmService.requestOrCheckNotificationPermission()
    }
}

// extension for everything related to food
extension LeiterbereichViewModel {
    
    var ordersState: UiState<[FoodOrder]> {
        switch usersState {
        case .loading(let usersSubState):
            return .loading(subState: usersSubState)
        case .error(let usersMessage):
            return .error(message: usersMessage)
        case .success(let users):
            switch ordersStateDto {
            case .loading(let ordersSubState):
                return .loading(subState: ordersSubState)
            case .error(let ordersMessage):
                return .error(message: ordersMessage)
            case .success(let orders):
                let transformedOrders = orders.map { $0.toFoodOrder(users: users) }
                return .success(data: transformedOrders)
            }
        }
    }
    
    private var newFoodOrder: FoodOrderDto {
        FoodOrderDto(
            itemDescription: self.newFoodItemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            userIds: Array(repeating: user.userId, count: self.newFoodItemCount)
        )
    }
    private var isNewFoodOrderOk: Bool {
        if newFoodOrder.itemDescription.isEmpty {
            return false
        }
        return true
    }
    var modifyOrderErrorBinding: Binding<Bool> {
        Binding(
            get: { self.modifyOrderErrorMessage != nil },
            set: { isSnackbarShown in
                if !isSnackbarShown {
                    withAnimation {
                        self.modifyOrderErrorMessage = nil
                    }
                }
            }
        )
    }
    
    func loadFoodData() async {
        
        var tasks: [() async -> Void] = []
        
        tasks.append {
            await self.observeUsers()
        }
        tasks.append {
            await self.observeOrders()
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    private func observeOrders() async {
        withAnimation {
            ordersStateDto = .loading(subState: .loading)
        }
        for await result in leiterbereichService.observeFoodOrders() {
            switch result {
            case .error(let e):
                withAnimation {
                    ordersStateDto = .error(message: "Bestellungen konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    ordersStateDto = .success(data: d)
                }
            }
        }
    }
    
    func addNewFoodOrder() async {
        if !isNewFoodOrderOk {
            withAnimation {
                addNewOrderState = .error(action: (), message: "Die Bestellung ist leer und kann nicht gespeichert werden.")
            }
            return
        }
        withAnimation {
            addNewOrderState = .loading(action: ())
        }
        let result = await leiterbereichService.addNewFoodOrder(order: newFoodOrder)
        switch result {
        case .error(let e):
            withAnimation {
                addNewOrderState = .error(action: (), message: "Die Bestellung konnte nicht gespeichert werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                showInsertFoodSheet = false
                addNewOrderState = .success(action: (), message: "Bestellung erfolgreich gespeichert")
                newFoodItemCount = 1
                newFoodItemDescription = ""
            }
        }
    }
    func deleteFromExistingOrder(orderId: String) async {
        
        let result = await leiterbereichService.deleteFromExistingOrder(userId: user.userId, orderId: orderId)
        if case .error(let e) = result {
            withAnimation {
                modifyOrderErrorMessage = "Beim Entfernen der Bestellung ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
        }
    }
    func addToExistingOrder(orderId: String) async {
        
        let result = await leiterbereichService.addToExistingOrder(userId: user.userId, orderId: orderId)
        if case .error(let e) = result {
            withAnimation {
                modifyOrderErrorMessage = "Beim Hinzufügen der Bestellung ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
        }
    }
    func deleteAllOrders() async {
        
        switch ordersState {
        case .success(let orders):
            withAnimation {
                deleteAllOrdersState = .loading(action: ())
            }
            let result = await leiterbereichService.deleteAllOrders(orders: orders)
            switch result {
            case .error(let e):
                withAnimation {
                    deleteAllOrdersState = .error(action: (), message: "Bestellungen konnten nicht gelöscht werden. \(e.defaultMessage)")
                }
            case .success(_):
                withAnimation {
                    deleteAllOrdersState = .success(action: (), message: "Bestellungen erfolgreich gelöscht")
                }
            }
        default:
            return
        }
    }
}

// extension for schöpflialarm
extension LeiterbereichViewModel {
    
    var schoepflialarmResult: UiState<Schoepflialarm> {
        
        let genericErrorMessage = "Der letzte Schöpflialarm konnte nicht geladen werden."
        
        switch usersState {
        case .loading(let usersSubState):
            return .loading(subState: usersSubState)
        case .error(let usersErrorMessage):
            return .error(message: genericErrorMessage + " " + usersErrorMessage)
        case .success(let users):
            
            switch schoepflialarmResultDto {
            case .loading(let schoepflialarmSubState):
                return .loading(subState: schoepflialarmSubState)
            case .error(let schoepflialarmErrorMessage):
                return .error(message: genericErrorMessage + " " + schoepflialarmErrorMessage)
            case .success(let schoepflialarmDto):
                
                switch schoepflialarmReactionsResultDto {
                case .loading(let reactionsSubState):
                    return .loading(subState: reactionsSubState)
                case .error(let reactionsErrorMessage):
                    return .error(message: genericErrorMessage + " " + reactionsErrorMessage)
                case .success(let reactionsDto):
                    
                    do {
                        let schoepflialarm = try schoepflialarmDto.toSchoepflialarm(users: users, reactions: reactionsDto)
                        return .success(data: schoepflialarm)
                    }
                    catch {
                        return .error(message: genericErrorMessage + " " + error.localizedDescription)
                    }
                }
            }
        }
    }
    private var schoepflialarmMessageType: SchoepflialarmMessageType {
        let message = schoepflialarmMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        switch message.isEmpty {
        case true:
            return .generic
        case false:
            return .custom(message: message)
        }
    }
    var schoepflialarmConfirmationText: String {
        switch schoepflialarmMessageType {
        case .generic:
            return "Der Schöpflialarm wird ohne Nachricht gesendet."
        case .custom(_):
            return "Möchtest du den Schöpflialarm wirklich senden?"
        }
    }
    
    func observeSchoepflialarm() async {
        withAnimation {
            schoepflialarmResultDto = .loading(subState: .loading)
        }
        for await result in schoepflialarmService.observeSchoepflialarm() {
            switch result {
            case .error(let e):
                withAnimation {
                    schoepflialarmResultDto = .error(message: "Der letzte Schöpflialarm konnte nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    schoepflialarmResultDto = .success(data: d)
                }
            }
        }
    }
    func observeSchoepflialarmReactions() async {
        withAnimation {
            schoepflialarmReactionsResultDto = .loading(subState: .loading)
        }
        for await result in schoepflialarmService.observeSchoepflialarmReactions() {
            switch result {
            case .error(let e):
                withAnimation {
                    schoepflialarmReactionsResultDto = .error(message: "Der letzte Schöpflialarm konnte nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    schoepflialarmReactionsResultDto = .success(data: d)
                }
            }
        }
    }
    
    func trySendSchoepflialarm() {
        withAnimation {
            showConfirmSchoepflialarmAlert = true
        }
    }
    
    func sendSchoepflialarm() async {
        
        withAnimation {
            sendSchoepflialarmState = .loading(action: ())
        }
        let result = await schoepflialarmService.sendSchöpflialarm(
            messageType: schoepflialarmMessageType,
            user: user
        )
        switch result {
        case .error(let e):
            switch e {
            case .messagingPermissionMissing:
                withAnimation {
                    sendSchoepflialarmState = .idle
                    showNotificationSettingsAlert = true
                }
            case .locationPermissionMissing:
                withAnimation {
                    sendSchoepflialarmState = .idle
                    showLocationSettingsAlert = true
                }
            default:
                withAnimation {
                    sendSchoepflialarmState = .error(action: (), message: e.defaultMessage)
                }
            }
        case .success(_):
            withAnimation {
                schoepflialarmMessage = ""
                sendSchoepflialarmState = .success(action: (), message: "Schöpflialarm erfolgreich gesendet")
            }
        }
    }
    
    func sendSchoepflialarmReaction(reaction: SchoepflialarmReactionType) async {
        
        withAnimation {
            sendSchoepflialarmReactionState = .loading(action: reaction)
        }
        let result = await schoepflialarmService.sendSchoepflialarmReaction(
            user: user,
            reaction: reaction
        )
        switch result {
        case .error(let e):
            withAnimation {
                sendSchoepflialarmReactionState = .error(action: reaction, message: "Beim Senden der Reaktion ist ein Fehler aufgetreten. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                sendSchoepflialarmReactionState = .success(action: reaction, message: "Reaktion erfolgreich gesendet")
            }
        }
    }
    
    func toggleSchoepflialarmReactionTopic(isSwitchingOn: Bool) async {
        
        let topic = SeesturmFCMNotificationTopic.schoepflialarmReaction
        withAnimation {
            toggleSchoepflialarmReactionsPushNotificationState = .loading(action: topic)
        }
        if isSwitchingOn {
            await subscribe(topic: topic)
        }
        else {
            await unsubscribe(topic: topic)
        }
    }
    
    private func subscribe(topic: SeesturmFCMNotificationTopic) async {
        
        let result = await fcmService.subscribe(to: topic)
        switch result {
        case .error(let e):
            switch e {
            case .permissionError:
                withAnimation {
                    toggleSchoepflialarmReactionsPushNotificationState = .idle
                    showNotificationSettingsAlert = true
                }
            default:
                withAnimation {
                    toggleSchoepflialarmReactionsPushNotificationState = .error(action: topic, message: e.defaultMessage)
                }
            }
        case .success(_):
            withAnimation {
                toggleSchoepflialarmReactionsPushNotificationState = .success(action: topic, message: "Anmeldung für \(topic.topicName) erfolgreich.")
            }
        }
    }
    
    private func unsubscribe(topic: SeesturmFCMNotificationTopic) async {
        let result = await fcmService.unsubscribe(from: topic)
        switch result {
        case .error(let e):
            withAnimation {
                toggleSchoepflialarmReactionsPushNotificationState = .error(action: topic, message: e.defaultMessage)
            }
        case .success(_):
            withAnimation {
                toggleSchoepflialarmReactionsPushNotificationState = .success(action: topic, message: "Abmeldung von \(topic.topicName) erfolgreich.")
            }
        }
    }
}
