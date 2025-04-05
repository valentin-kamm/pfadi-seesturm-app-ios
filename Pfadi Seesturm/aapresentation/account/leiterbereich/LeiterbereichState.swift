//
//  LeiterbereichState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.03.2025.
//

struct LeiterbereichState {
    var termineState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var usersState: UiState<[FirebaseHitobitoUser]> = .loading(subState: .idle)
    var ordersStateDto: UiState<[FoodOrderDto]> = .loading(subState: .idle)
    var showSignOutConfirmationDialog: Bool = false
    var showDeleteAccountConfirmationDialog: Bool = false
    var showInsertFoodSheet: Bool = false
    var addNewOrderState: ActionState<Void> = .idle
    var showDeleteAllOrdersDialog: Bool = false
    var deleteAllOrdersState: ActionState<Void> = .idle
    var modifyOrderErrorMessage: String? = nil
    var newFoodItemDescription: String = ""
    var newFoodItemCount: Int = 1
}
