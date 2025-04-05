//
//  LeiterbereichViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

import SwiftUI

class LeiterbereichViewModel: StateManager<LeiterbereichState> {
    
    private let service: LeiterbereichService
    private let calendar: SeesturmCalendar
    private let userId: String
    init(
        service: LeiterbereichService,
        calendar: SeesturmCalendar,
        userId: String
    ) {
        self.service = service
        self.calendar = calendar
        self.userId = userId
        super.init(initialState: LeiterbereichState())
    }
    
    // combine users and orders listeners
    var ordersState: UiState<[FoodOrder]> {
        switch state.usersState {
        case .loading(let usersSubState):
            return .loading(subState: usersSubState)
        case .error(let usersMessage):
            return .error(message: usersMessage)
        case .success(let users):
            switch state.ordersStateDto {
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
    
    var signOutConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showSignOutConfirmationDialog },
            set: { newValue in
                self.changeSignOutConfirmationDialogVisibility(isVisible: newValue)
            }
        )
    }
    var deleteAccountConfirmationDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showDeleteAccountConfirmationDialog },
            set: { newValue in
                self.changeDeleteAccountConfirmationDialogVisibility(isVisible: newValue)
            }
        )
    }
    var showInsertFoodSheetBinding: Binding<Bool> {
        Binding(
            get: { self.state.showInsertFoodSheet },
            set: { newValue in
                self.changeShowInsertFoodSheet(isVisible: newValue)
            }
        )
    }
    var showDeleteAllOrdersDialogBinding: Binding<Bool> {
        Binding(
            get: { self.state.showDeleteAllOrdersDialog },
            set: { newValue in
                self.changeDeleteAllOrdersDialogVisibility(isVisible: newValue)
            }
        )
    }
    var deleteAllOrdersStateBinding: Binding<ActionState<Void>> {
        Binding(
            get: { self.state.deleteAllOrdersState },
            set: { newValue in
                self.updateState { state in
                    state.deleteAllOrdersState = newValue
                }
            }
        )
    }
    var modifyOrderErrorBinding: Binding<Bool> {
        Binding(
            get: { self.state.modifyOrderErrorMessage != nil },
            set: { isSnackbarShown in
                if !isSnackbarShown {
                    self.updateState { state in
                        state.modifyOrderErrorMessage = nil
                    }
                }
            }
        )
    }
    var addNewOrderStateBinding: Binding<ActionState<Void>> {
        Binding(
            get: { self.state.addNewOrderState },
            set: { newValue in
                self.updateState { state in
                    state.addNewOrderState = newValue
                }
            }
        )
    }
    var newFoodItemDescriptionBinding: Binding<String> {
        Binding(
            get: { self.state.newFoodItemDescription },
            set: { newValue in
                self.updateState { state in
                    state.newFoodItemDescription = newValue
                }
            }
        )
    }
    var newFoodItemCountBinding: Binding<Int> {
        Binding(
            get: { self.state.newFoodItemCount },
            set: { newValue in
                self.updateState { state in
                    state.newFoodItemCount = newValue
                }
            }
        )
    }
    private var newFoodOrder: FoodOrderDto {
        FoodOrderDto(
            itemDescription: self.state.newFoodItemDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            userIds: Array(repeating: userId, count: self.state.newFoodItemCount)
        )
    }
    private var isNewFoodOrderOk: Bool {
        if newFoodOrder.itemDescription.isEmpty {
            return false
        }
        return true
    }
    
    func loadData() async {
        
        var tasks: [() async -> Void] = []
        
        if state.termineState.taskShouldRun {
            tasks.append {
                await self.fetchNext3Events()
            }
        }
        tasks.append {
            await self.loadFoodData()
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
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
    
    private func observeUsers() async {
        updateState { state in
            state.usersState = .loading(subState: .loading)
        }
        for await result in service.observeUsers() {
            switch result {
            case .error(let e):
                updateState { state in
                    state.usersState = .error(message: "Benutzer konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                updateState { state in
                    state.usersState = .success(data: d)
                }
            }
        }
    }
    
    private func observeOrders() async {
        updateState { state in
            state.ordersStateDto = .loading(subState: .loading)
        }
        for await result in service.observeFoodOrders() {
            switch result {
            case .error(let e):
                updateState { state in
                    state.ordersStateDto = .error(message: "Bestellungen konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                updateState { state in
                    state.ordersStateDto = .success(data: d)
                }
            }
        }
    }
    
    func fetchNext3Events() async {
        updateState { state in
            state.termineState = .loading(subState: .loading)
        }
        let result = await service.getNext3Events(calendar: calendar)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.termineState = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.termineState = .error(message: "Die nächsten Termine konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.termineState = .success(data: d.items)
            }
        }
    }
    
    func changeSignOutConfirmationDialogVisibility(isVisible: Bool) {
        updateState { state in
            state.showSignOutConfirmationDialog = isVisible
        }
    }
    func changeDeleteAccountConfirmationDialogVisibility(isVisible: Bool) {
        updateState { state in
            state.showDeleteAccountConfirmationDialog = isVisible
        }
    }
    func changeShowInsertFoodSheet(isVisible: Bool) {
        updateState { state in
            state.showInsertFoodSheet = isVisible
        }
    }
    func changeDeleteAllOrdersDialogVisibility(isVisible: Bool) {
        updateState { state in
            state.showDeleteAllOrdersDialog = isVisible
        }
    }
    
    func addNewFoodOrder() async {
        if !isNewFoodOrderOk {
            updateState { state in
                state.addNewOrderState = .error(action: (), message: "Die Bestellung ist leer und kann nicht gespeichert werden.")
            }
            return
        }
        updateState { state in
            state.addNewOrderState = .loading(action: ())
        }
        let result = await service.addNewFoodOrder(order: newFoodOrder)
        switch result {
        case .error(let e):
            updateState { state in
                state.addNewOrderState = .error(action: (), message: "Die Bestellung konnte nicht gespeichert werden. \(e.defaultMessage)")
            }
        case .success(_):
            updateState { state in
                state.showInsertFoodSheet = false
                state.addNewOrderState = .success(action: (), message: "Bestellung erfolgreich gespeichert")
                state.newFoodItemCount = 1
                state.newFoodItemDescription = ""
            }
        }
    }
    func deleteFromExistingOrder(orderId: String) async {
        
        let result = await service.deleteFromExistingOrder(userId: userId, orderId: orderId)
        if case .error(let e) = result {
            updateState { state in
                state.modifyOrderErrorMessage = "Beim Entfernen der Bestellung ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
        }
    }
    func addToExistingOrder(orderId: String) async {
        
        let result = await service.addToExistingOrder(userId: userId, orderId: orderId)
        if case .error(let e) = result {
            updateState { state in
                state.modifyOrderErrorMessage = "Beim Hinzufügen der Bestellung ist ein Fehler aufgetreten. \(e.defaultMessage)"
            }
        }
    }
    func deleteAllOrders() async {
        switch ordersState {
        case .success(let orders):
            updateState { state in
                state.deleteAllOrdersState = .loading(action: ())
            }
            let result = await service.deleteAllOrders(orders: orders)
            switch result {
            case .error(let e):
                updateState { state in
                    state.deleteAllOrdersState = .error(action: (), message: "Bestellungen konnte nicht gelöscht werden. \(e.defaultMessage)")
                }
            case .success(_):
                updateState { state in
                    state.deleteAllOrdersState = .success(action: (), message: "Bestellungen erfolgreich gelöscht")
                }
            }
        default:
            return
        }
    }
    
    /*
    // current user
    private var currentUser: FirebaseHitobitoUser
    
    // variables for sending schöpflialarm
    @Published var sendSchöpflialarmLoadingState: SeesturmLoadingState<String, PfadiSeesturmAppError>
    @Published var schöpflialarmMessage: String
    @Published var showLocationSettingsAlert: Bool
    @Published var showLocationAccuracySettingsAlert: Bool
    @Published var showNotificationsSettingsAlert: Bool
    @Published var showWirklichSendenAlert: Bool
    @Published var wirklichSendenContinuation: CheckedContinuation<Void, Error>?
    
    // variables for reading termine
    @Published var termineLoadingState: SeesturmLoadingState<[GoogleCalendarEvent], PfadiSeesturmAppError>
    let calendarNetworkManager = CalendarNetworkManager.shared
    
    // variables for reading essensbestellungen
    @Published private var rawOrdersLoadingState: SeesturmLoadingState<[FirestoreFoodOrder], PfadiSeesturmAppError>
    private var ordersObservationTask: Task<Void, Never>?
    
    // variables for reading users
    @Published private var rawUsersLoadingState: SeesturmLoadingState<[FirebaseHitobitoUser], PfadiSeesturmAppError>
    private var usersObservationTask: Task<Void, Never>?
    
    // variables for reading last schöpflialarm
    @Published private var rawLastSchöpflialarmLoadingState: SeesturmLoadingState<Schöpflialarm?, PfadiSeesturmAppError>
    private var schöpflialarmObservationTask: Task<Void, Never>?
    
    // variable for selected Stufen
    private var userDefaultsKeySelectedStufen = "selectedStufenLeiterbereich_V2"
    @Published var selectedStufen: Set<SeesturmStufeOld> = [SeesturmStufeOld.biber, SeesturmStufeOld.wolf, SeesturmStufeOld.pfadi, SeesturmStufeOld.pio] {
        didSet {
            saveSelectedStufen()
        }
    }
    
    init(
        currentUser: FirebaseHitobitoUser,
        sendSchöpflialarmLoadingState: SeesturmLoadingState<String, PfadiSeesturmAppError> = .none,
        schöpflialarmMessage: String = "",
        showLocationSettingsAlert: Bool = false,
        showLocationAccuracySettingsAlert: Bool = false,
        showNotificationsSettingsAlert: Bool = false,
        showWirklichSendenAlert: Bool = false,
        termineLoadingState: SeesturmLoadingState<[GoogleCalendarEvent], PfadiSeesturmAppError> = .none,
        rawOrdersLoadingState: SeesturmLoadingState<[FirestoreFoodOrder], PfadiSeesturmAppError> = .none,
        rawUsersLoadingState: SeesturmLoadingState<[FirebaseHitobitoUser], PfadiSeesturmAppError> = .none,
        usersObservationTask: Task<Void, Never>? = nil,
        rawLastSchöpflialarmLoadingState: SeesturmLoadingState<Schöpflialarm?, PfadiSeesturmAppError> = .none,
        schöpflialarmObservationTask: Task<Void, Never>? = nil
    ) {
        self.currentUser = currentUser
        self.sendSchöpflialarmLoadingState = sendSchöpflialarmLoadingState
        self.schöpflialarmMessage = schöpflialarmMessage
        self.showLocationSettingsAlert = showLocationSettingsAlert
        self.showLocationAccuracySettingsAlert = showLocationAccuracySettingsAlert
        self.showNotificationsSettingsAlert = showNotificationsSettingsAlert
        self.showWirklichSendenAlert = showWirklichSendenAlert
        self.termineLoadingState = termineLoadingState
        self.rawOrdersLoadingState = rawOrdersLoadingState
        self.rawUsersLoadingState = rawUsersLoadingState
        self.rawLastSchöpflialarmLoadingState = rawLastSchöpflialarmLoadingState
        
        startObservingLeiterbereichData()
        withAnimation {
            self.selectedStufen = getSelectedStufen()
        }
    }
    
    deinit {
        schöpflialarmObservationTask?.cancel()
        schöpflialarmObservationTask = nil
        usersObservationTask?.cancel()
        usersObservationTask = nil
        ordersObservationTask?.cancel()
        ordersObservationTask = nil
    }
    
    // variables for reading combined values for schöpflialarm and essensbestellungen
    var lastSchöpflialarmLoadingState: SeesturmLoadingState<TransformedSchöpflialarm?, PfadiSeesturmAppError> {
        return FirestoreManager.shared.combineTwoLoadingStates(
            state1: rawLastSchöpflialarmLoadingState,
            state2: rawUsersLoadingState) { schöpflialarm, users in
                if let sa = schöpflialarm {
                    return try sa.toTransformedSchöpflialarm(users: users)
                }
                else {
                    return nil
                }
            }
    }
    var foodOrdersLoadingState: SeesturmLoadingState<[TransformedFirestoreFoodOrder], PfadiSeesturmAppError> {
        return FirestoreManager.shared.combineTwoLoadingStates(
            state1: rawOrdersLoadingState,
            state2: rawUsersLoadingState) { orders, users in
                return try orders.map { try $0.toTransformedOrder(users: users)}
            }
    }
    
    // function to start all observers
    func startObservingLeiterbereichData() {
        observeSchöpflialarm()
        observeUsers()
        observeOrders()
    }
    
    // function to observe essensbestellungen
    private func observeOrders() {
        ordersObservationTask?.cancel()
        ordersObservationTask = nil
        withAnimation {
            rawOrdersLoadingState = .loading
        }
        ordersObservationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
            do {
                let collection = FirestoreManager.FirestoreStructure.FirestoreLeiterbereichCollection.FirestoreFoodDocument.FirestoreOrdersCollection.collection
                for try await data in FirestoreManager.shared.observeCollection(collectionReference: collection, as: FirestoreFoodOrder.self) {
                    withAnimation {
                        self.rawOrdersLoadingState = .result(.success(data))
                    }
                }
                withAnimation {
                    self.rawUsersLoadingState = .none
                }
            }
            catch let pfadiSeesturmError as PfadiSeesturmAppError {
                withAnimation {
                    self.rawOrdersLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
            catch {
                let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
                withAnimation {
                    self.rawOrdersLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
    }
    
    // function that observes users
    private func observeUsers() {
        usersObservationTask?.cancel()
        usersObservationTask = nil
        withAnimation {
            rawUsersLoadingState = .loading
        }
        usersObservationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
            do {
                let collection = FirestoreManager.FirestoreStructure.FirestoreUserCollection.collection
                for try await data in FirestoreManager.shared.observeCollection(collectionReference: collection, as: FirebaseHitobitoUser.self) {
                    withAnimation {
                        self.rawUsersLoadingState = .result(.success(data))
                    }
                }
                withAnimation {
                    self.rawUsersLoadingState = .none
                }
            }
            catch let pfadiSeesturmError as PfadiSeesturmAppError {
                withAnimation {
                    self.rawUsersLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
            catch {
                let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
                withAnimation {
                    self.rawUsersLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
    }
    
    // function to observe last schöpflialarm
    private func observeSchöpflialarm() {
        schöpflialarmObservationTask?.cancel()
        schöpflialarmObservationTask = nil
        withAnimation {
            rawLastSchöpflialarmLoadingState = .loading
        }
        schöpflialarmObservationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
            do {
                let docRef = FirestoreManager.FirestoreStructure.FirestoreLeiterbereichCollection.FirestoreSchopflialarmDocument.document
                for try await data in FirestoreManager.shared.observeSingleDocument(documentReference: docRef, as: Schöpflialarm.self) {
                    withAnimation {
                        self.rawLastSchöpflialarmLoadingState = .result(.success(data))
                    }
                }
                // observation has stopped
                withAnimation {
                    self.rawLastSchöpflialarmLoadingState = .none
                }
            }
            catch let pfadiSeesturmError as PfadiSeesturmAppError {
                withAnimation {
                    self.rawLastSchöpflialarmLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
            catch {
                let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
                withAnimation {
                    self.rawLastSchöpflialarmLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
    }
    
    // function to send schöpflialarm
    func sendSchöpflialarm() async {
        if schöpflialarmMessage.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            showWirklichSendenAlert = true
            do {
                try await withCheckedThrowingContinuation { continuation in
                    self.wirklichSendenContinuation = continuation
                }
            }
            catch {
                withAnimation {
                    self.sendSchöpflialarmLoadingState = .none
                }
                return
            }
        }
        let sendingManager = SchöpflialarmSendingManager(message: self.schöpflialarmMessage, user: currentUser)
        await sendingManager.sendSchöpflialarm(
            showNotificationsSettingsAlert: {
                self.showNotificationsSettingsAlert = true
            },
            showLocationSettingsAlert: {
                self.showLocationSettingsAlert = true
            },
            showLocationAccuracySettingsAlert: {
                self.showLocationAccuracySettingsAlert = true
            },
            onNewState: { newState in
                withAnimation {
                    self.sendSchöpflialarmLoadingState = newState
                }
            }
        )
    }
    
    // function to fetch the next 3 events
    func fetchNext3LeiterbereichEvents(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.termineLoadingState = isPullToRefresh ? termineLoadingState : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: SeesturmCalendar.termineLeitungsteam.data.calendarId, includePast: false, maxResults: 3)
            let transformedResponse = try response.toGoogleCalendarEvents()
            withAnimation {
                self.termineLoadingState = .result(.success(transformedResponse.items))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.termineLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.termineLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: error.localizedDescription)
            withAnimation {
                self.termineLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to get the selected stufen
    private func getSelectedStufen() -> Set<SeesturmStufeOld> {
        let data = UserDefaults().data(forKey: userDefaultsKeySelectedStufen) ?? Data()
        guard !data.isEmpty else {
            return [SeesturmStufeOld.biber, SeesturmStufeOld.wolf, SeesturmStufeOld.pfadi, SeesturmStufeOld.pio]
        }
        let set = try? JSONDecoder().decode(Set<SeesturmStufeOld>.self, from: data)
        return set ?? [SeesturmStufeOld.biber, SeesturmStufeOld.wolf, SeesturmStufeOld.pfadi, SeesturmStufeOld.pio]
    }
    
    // function to save the selected stufen
    private func saveSelectedStufen() {
        let data = try? JSONEncoder().encode(selectedStufen)
        UserDefaults().set(data, forKey: userDefaultsKeySelectedStufen)
    }
    
     */
}
