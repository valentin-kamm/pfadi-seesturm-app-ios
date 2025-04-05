//
//  StufenbereichView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichView: View {
    
    @StateObject var viewModel: StufenbereichViewModel
    @Environment(\.accountModule) var accountModule: AccountModule
    let stufe: SeesturmStufe
    
    var body: some View {
        List {
            Section {
                switch viewModel.abmeldungenState {
                case .loading(_):
                    ForEach(0..<6) { index in
                        StufenbereichAnAbmeldungLoadingCell()
                            .padding(.top, index == 0 ? 16 : 0)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                case .error(let message):
                    CardErrorView(
                        errorDescription: message,
                        asyncRetryAction: {
                            await viewModel.getAktivitaeten(isPullToRefresh: false)
                        }
                    )
                    .padding(.top)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                case .success(let data):
                    let aktivitaeten = data.filter { $0.event.endDate > viewModel.state.selectedDate }.sorted { $0.event.startDate > $1.event.startDate }
                    if aktivitaeten.isEmpty {
                        Text("Keine Daten vorhanden")
                            .padding(.horizontal)
                            .padding(.vertical, 75)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.secondary)
                    }
                    else {
                        ForEach(Array(aktivitaeten.enumerated()), id: \.element.event.id) { index, event in
                            StufenbereichAnAbmeldungCell(
                                aktivitaet: event,
                                stufe: stufe,
                                selectedAktivitaetInteraction: viewModel.state.selectedAktivitaetInteraction,
                                isBearbeitenButtonLoading: viewModel.isEditButtonLoading(aktivitaet: event),
                                onSendPushNotification: {
                                    Task {
                                        await viewModel.sendPushNotification(aktivitaet: event)
                                    }
                                },
                                onDeleteAnAbmeldungen: {
                                    Task {
                                        await viewModel.deleteAnAbmeldungenForAktivitaet(aktivitaet: event)
                                    }
                                },
                                onEditAktivitaet: {
                                    viewModel.updateSheetMode(newMode: .update(id: event.event.id))
                                },
                                onChangeSelectedAktivitaetInteraction: { interaction in
                                    viewModel.updateSelectedAktivitaetInteraction(newInteraction: interaction)
                                }
                            )
                            .padding(.top, index == 0 ? 16 : 0)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            } header: {
                VStack(alignment: .trailing, spacing: 8) {
                    DatePicker("Aktivitäten ab", selection: viewModel.selectedDateBinding, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(Color.SEESTURM_GREEN)
                        .disabled(!viewModel.abmeldungenState.isSuccess)
                    Picker("An-/Abmeldung", selection: viewModel.selectedAktivitaetInteractionBinding) {
                        ForEach(stufe.allowedAktivitaetInteractions, id: \.self) { interaction in
                            Label(interaction.nomenMehrzahl, systemImage: interaction.icon)
                                .labelStyle(.titleAndIcon)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(viewModel.state.selectedAktivitaetInteraction.color)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical)
            }
        }
        .navigationTitle(stufe.stufenName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .listStyle(.plain)
        .scrollDisabled(viewModel.abmeldungenState.scrollingDisabled)
        .task {
            await viewModel.loadData()
        }
        .sheet(isPresented: viewModel.showSheetBinding) {
            AktivitaetBearbeitenView(
                viewModel: AktivitaetBearbeitenViewModel(
                    selectedSheetMode: viewModel.state.selectedSheetMode,
                    service: accountModule.stufenbereichService,
                    stufe: stufe,
                    onPublishAktivitaetStateChange: { state in
                        viewModel.updatePublishAktivitaetState(newState: state)
                    },
                    onDismiss: {
                        viewModel.updateSheetMode(newMode: .hidden)
                    }
                ),
                stufe: stufe
            )
        }
        .refreshable {
            await viewModel.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.abmeldungenState.isSuccess {
                    switch viewModel.state.deleteAllAbmeldungenState {
                    case .loading(_):
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    default:
                        Button {
                            viewModel.updateShowDeleteAllAbmeldungenConfirmationDialog(isVisible: true)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.SEESTURM_GREEN)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.updateSheetMode(newMode: .insert)
                } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(Color.SEESTURM_GREEN)
                }
            }
        }
        .confirmationDialog("Die An- und Abmeldungen der ausgewählten Aktivität werden gelöscht. Fortfahren?", isPresented: viewModel.showDeleteAbmeldungenConfirmationDialogBinding, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                viewModel.deleteAbmeldungenContinuation?.resume(returning: false)
            }
            Button("Löschen", role: .destructive) {
                viewModel.deleteAbmeldungenContinuation?.resume(returning: true)
            }
        }
        .confirmationDialog("Die An- und Abmeldungen aller vergangenen Aktivitäten werden gelöscht. Fortfahren?", isPresented: viewModel.showDeleteAllAbmeldungenConfirmationDialogBinding, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                // do nothing
            }
            Button("Löschen", role: .destructive) {
                Task {
                    await viewModel.deleteAllAnAbmeldungen()
                }
            }
        }
        .confirmationDialog("Für die ausgewählte Aktivität wird eine Push-Nachricht versendet. Fortfahren?", isPresented: viewModel.showSendPushNotificationConfirmationDialogBinding, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                viewModel.sendPushNotificationContinuation?.resume(returning: false)
            }
            Button("Senden", role: .destructive) {
                viewModel.sendPushNotificationContinuation?.resume(returning: true)
            }
        }
        .actionSnackbar(
            action: viewModel.publishAktivitaetStateBinding,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .actionSnackbar(
            action: viewModel.deleteAbmeldungenStateBinding,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .actionSnackbar(
            action: viewModel.deleteAllAbmeldungenStateBinding,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .actionSnackbar(
            action: viewModel.sendPushNotificationStateBinding,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
    }
}

enum StufenbereichSheetMode: Hashable {
    case hidden
    case update(id: String)
    case insert
}

#Preview {
    StufenbereichView(
        viewModel: StufenbereichViewModel(
            stufe: .biber,
            service: StufenbereichService(
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
                ),
                cloudFunctionsRepository: CloudFunctionsRepositoryImpl(
                    api: CloudFunctionsApiImpl(
                        functions: .functions()
                    )
                )
            ),
            initialSheetMode: .hidden
        ),
        stufe: .biber
    )
}
