//
//  EssenBestellenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI

struct EssenBestellenView: View {
    
    @ObservedObject var viewModel: LeiterbereichViewModel
    let user: FirebaseHitobitoUser
    
    var body: some View {
        List {
            switch viewModel.ordersState {
            case .loading(_):
                ForEach(1..<10) { _ in
                    EssenBestellungLoadingCell()
                }
            case .error(let message):
                CardErrorView(
                    errorDescription: message
                )
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            case .success(let orders):
                let ordersFiltered = orders.filter( { $0.userIds.count > 0 })
                if !ordersFiltered.isEmpty {
                    ForEach(ordersFiltered, id: \.id) { order in
                        EssenBestellungCell(
                            order: order,
                            user: user,
                            onDeleteButtonClick: {
                                Task {
                                    await viewModel.deleteFromExistingOrder(orderId: order.id)
                                }
                            },
                            onAddButtonClick: {
                                Task {
                                    await viewModel.addToExistingOrder(orderId: order.id)
                                }
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
                            style: .primary,
                            action: .sync(action: {
                                viewModel.changeShowInsertFoodSheet(isVisible: true)
                            }),
                            title: "Bestellung hinzufügen"
                        )
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle("Essen bestellen")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .myListStyle(isListPlain: viewModel.ordersState.isError)
        .sheet(isPresented: viewModel.showInsertFoodSheetBinding) {
            BestellungHinzufuegenView(
                newFoodItemDescription: viewModel.newFoodItemDescriptionBinding,
                newFoodItemCount: viewModel.newFoodItemCountBinding,
                isButtonLoading: viewModel.state.addNewOrderState.isLoading,
                addNewOrderStateBinding: viewModel.addNewOrderStateBinding,
                onSubmit: {
                    Task {
                        await viewModel.addNewFoodOrder()
                    }
                }
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if case .success(let orders) = viewModel.ordersState, orders.filter( { $0.userIds.count > 0 }).count > 0 {
                    if viewModel.state.deleteAllOrdersState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    else {
                        Button {
                            viewModel.changeDeleteAllOrdersDialogVisibility(isVisible: true)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.SEESTURM_GREEN)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.changeShowInsertFoodSheet(isVisible: true)
                } label: {
                    Image(systemName: "plus")
                        .tint(Color.SEESTURM_GREEN)
                }
            }
        }
        .confirmationDialog("Alle Bestellungen werden gelöscht", isPresented: viewModel.showDeleteAllOrdersDialogBinding, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                viewModel.changeDeleteAllOrdersDialogVisibility(isVisible: false)
            }
            Button("Löschen", role: .destructive) {
                Task {
                    await viewModel.deleteAllOrders()
                }
            }
        }
        .actionSnackbar(
            action: viewModel.deleteAllOrdersStateBinding,
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
            message: viewModel.state.modifyOrderErrorMessage ?? "Beim Bearbeiten der Bestellung ist ein unbekannter Fehler aufgetreten.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
        .actionSnackbar(
            action: viewModel.addNewOrderStateBinding,
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

#Preview {
    EssenBestellenView(
        viewModel: LeiterbereichViewModel(
            service: LeiterbereichService(
                termineRepository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: .firestore(),
                    api: FirestoreApiImpl(
                        db: .firestore()
                    )
                )
            ),
            calendar: .termineLeitungsteam,
            userId: "12313"
        ),
        user: FirebaseHitobitoUser(
            userId: "12313",
            vorname: "Sepp",
            nachname: "Müller",
            pfadiname: nil,
            email: "Test@test.test",
            created: Date(),
            createdFormatted: "",
            modified: Date(),
            modifiedFormatted: ""
        )
    )
}
