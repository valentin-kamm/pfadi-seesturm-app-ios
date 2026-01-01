//
//  OrdersView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI
import SwiftData

struct OrdersView: View {
    
    @Bindable private var viewModel: LeiterbereichViewModel
    private let user: FirebaseHitobitoUser
    
    init(
        viewModel: LeiterbereichViewModel,
        user: FirebaseHitobitoUser
    ) {
        self.viewModel = viewModel
        self.user = user
    }
    
    var body: some View {
        OrdersContentView(
            ordersState: viewModel.ordersState,
            deleteAllOrdersState: viewModel.deleteAllOrdersState,
            user: user,
            onDeleteFromOrder: viewModel.deleteFromExistingOrder,
            onAddToOrder: viewModel.addToExistingOrder,
            onShowSheet: {
                withAnimation {
                    viewModel.showInsertFoodSheet = true
                }
            },
            onDeleteAllOrders: {
                Task {
                    await viewModel.deleteAllOrders()
                }
            }
        )
        .sheet(isPresented: $viewModel.showInsertFoodSheet) {
            AddOrderView(
                newFoodItemDescription: $viewModel.newFoodItemDescription,
                newFoodItemCount: $viewModel.newFoodItemCount,
                addNewOrderState: $viewModel.addNewOrderState,
                onSubmit: {
                    Task {
                        await viewModel.addNewFoodOrder()
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .actionSnackbar(
            action: $viewModel.deleteAllOrdersState,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .customSnackbar(
            show: viewModel.modifyOrderErrorBinding,
            type: .error,
            message: viewModel.modifyOrderErrorMessage ?? "Beim Bearbeiten der Bestellung ist ein unbekannter Fehler aufgetreten.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
        .actionSnackbar(
            action: $viewModel.addNewOrderState,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .task {
            await viewModel.loadFoodData()
        }
    }
}

private struct OrdersContentView: View {
    
    @State private var showDeleteAllOrdersDialog: Bool = false
    
    private let ordersState: UiState<[FoodOrder]>
    private let deleteAllOrdersState: ActionState<Void>
    private let user: FirebaseHitobitoUser
    private let onDeleteFromOrder: (String) async -> Void
    private let onAddToOrder: (String) async -> Void
    private let onShowSheet: () -> Void
    private let onDeleteAllOrders: () -> Void
    
    init(
        ordersState: UiState<[FoodOrder]>,
        deleteAllOrdersState: ActionState<Void>,
        user: FirebaseHitobitoUser,
        onDeleteFromOrder: @escaping (String) async -> Void,
        onAddToOrder: @escaping (String) async -> Void,
        onShowSheet: @escaping () -> Void,
        onDeleteAllOrders: @escaping () -> Void
    ) {
        self.ordersState = ordersState
        self.deleteAllOrdersState = deleteAllOrdersState
        self.user = user
        self.onDeleteFromOrder = onDeleteFromOrder
        self.onAddToOrder = onAddToOrder
        self.onShowSheet = onShowSheet
        self.onDeleteAllOrders = onDeleteAllOrders
    }
    
    var body: some View {
        List {
            switch ordersState {
            case .loading(_):
                ForEach(1..<10) { _ in
                    FoodOrderLoadingCell()
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message
                )
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            case .success(let orders):
                let ordersFiltered = orders.filter( { $0.userIds.count > 0 })
                if !ordersFiltered.isEmpty {
                    ForEach(ordersFiltered) { order in
                        FoodOrderCell(
                            order: order,
                            user: user,
                            onDelete: {
                                await onDeleteFromOrder(order.id)
                            },
                            onAdd: {
                                await onAddToOrder(order.id)
                            }
                        )
                    }
                }
                else {
                    VStack(alignment: .center, spacing: 16) {
                        Image(systemName: "fork.knife")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                            .padding(.top, 24)
                        Text("Keine Bestellungen")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                        Text("Füge jetzt die erste Bestellung hinzu.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)
                        SeesturmButton(
                            type: .primary,
                            action: .sync(action: onShowSheet),
                            title: "Bestellung hinzufügen"
                        )
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle("Bestellungen")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if case .success(let orders) = ordersState, orders.filter( { $0.userIds.count > 0 }).count > 0 {
                    
                    if deleteAllOrdersState.isLoading {
                        SeesturmProgressView(
                            color: .SEESTURM_GREEN
                        )
                    }
                    else {
                        Button {
                            showDeleteAllOrdersDialog = true
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.SEESTURM_GREEN)
                        }
                        .confirmationDialog("Möchtest du alle Bestellungen löschen?", isPresented: $showDeleteAllOrdersDialog, titleVisibility: .visible) {
                            Button("Abbrechen", role: .cancel) {
                                // do nothing
                            }
                            Button("Löschen", role: .destructive) {
                                onDeleteAllOrders()
                            }
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onShowSheet()
                } label: {
                    Image(systemName: "plus")
                        .tint(Color.SEESTURM_GREEN)
                }
            }
        }
        .dynamicListStyle(isListPlain: ordersState.isError)
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        OrdersContentView(
            ordersState: .loading(subState: .loading),
            deleteAllOrdersState: .idle,
            user: DummyData.user1,
            onDeleteFromOrder: { _ in },
            onAddToOrder: { _ in },
            onShowSheet: {},
            onDeleteAllOrders: {}
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        OrdersContentView(
            ordersState: .error(message: "Schlimmer Fehler"),
            deleteAllOrdersState: .idle,
            user: DummyData.user1,
            onDeleteFromOrder: { _ in },
            onAddToOrder: { _ in },
            onShowSheet: {},
            onDeleteAllOrders: {}
        )
    }
}
#Preview("No orders") {
    NavigationStack(path: .constant(NavigationPath())) {
        OrdersContentView(
            ordersState: .success(data: []),
            deleteAllOrdersState: .idle,
            user: DummyData.user1,
            onDeleteFromOrder: { _ in },
            onAddToOrder: { _ in },
            onShowSheet: {},
            onDeleteAllOrders: {}
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        OrdersContentView(
            ordersState: .success(data: DummyData.foodOrders),
            deleteAllOrdersState: .loading(action: ()),
            user: DummyData.user1,
            onDeleteFromOrder: { _ in },
            onAddToOrder: { _ in },
            onShowSheet: {},
            onDeleteAllOrders: {}
        )
    }
}
