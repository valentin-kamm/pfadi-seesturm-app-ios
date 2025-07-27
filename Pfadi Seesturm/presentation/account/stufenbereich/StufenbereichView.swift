//
//  StufenbereichView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichView: View {
    
    @Environment(\.accountModule) private var accountModule: AccountModule
    @EnvironmentObject private var appState: AppStateViewModel
    
    @State private var viewModel: StufenbereichViewModel
    private let stufe: SeesturmStufe
    
    init(
        viewModel: StufenbereichViewModel,
        stufe: SeesturmStufe
    ) {
        self.viewModel = viewModel
        self.stufe = stufe
    }
    
    var body: some View {
        StufenbereichContentView(
            stufe: stufe,
            abmeldungenState: viewModel.abmeldungenState,
            deleteAllAbmeldungenState: viewModel.deleteAllAbmeldungenState,
            onGetAktivitaetenRetry: {
                Task {
                    await viewModel.getAktivitaeten(isPullToRefresh: false)
                }
            },
            selectedDate: $viewModel.selectedDate,
            selectedAktivitaetInteraction: $viewModel.selectedAktivitaetInteraction,
            isEditButtonLoading: viewModel.isEditButtonLoading,
            onSendPushNotification: { event in
                Task {
                    await viewModel.sendPushNotification(aktivitaet: event)
                }
            },
            onDeleteAnAbmeldungenForAktivitaet: { event in
                Task {
                    await viewModel.deleteAnAbmeldungenForAktivitaet(aktivitaet: event)
                }
            },
            onEditAktivitaet: { event in
                appState.appendToNavigationPath(
                    tab: .account,
                    destination: AccountNavigationDestination.aktivitaetBearbeiten(
                        mode: .update(id: event.event.id),
                        stufe: stufe
                    )
                )
            },
            showDeleteAllAbmeldungenConfirmationDialog: $viewModel.showDeleteAllAbmeldungenConfirmationDialog
        )
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.refresh()
        }
        .confirmationDialog("Die An- und Abmeldungen der ausgewählten Aktivität werden gelöscht. Fortfahren?", isPresented: $viewModel.showDeleteAbmeldungenConfirmationDialog, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                viewModel.deleteAbmeldungenContinuation?.resume(returning: false)
            }
            Button("Löschen", role: .destructive) {
                viewModel.deleteAbmeldungenContinuation?.resume(returning: true)
            }
        }
        .confirmationDialog("Die An- und Abmeldungen aller vergangenen Aktivitäten werden gelöscht. Fortfahren?", isPresented: $viewModel.showDeleteAllAbmeldungenConfirmationDialog, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                // do nothing
            }
            Button("Löschen", role: .destructive) {
                Task {
                    await viewModel.deleteAllAnAbmeldungen()
                }
            }
        }
        .confirmationDialog("Für die ausgewählte Aktivität wird eine Push-Nachricht versendet. Fortfahren?", isPresented: $viewModel.showSendPushNotificationConfirmationDialog, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {
                viewModel.sendPushNotificationContinuation?.resume(returning: false)
            }
            Button("Senden", role: .destructive) {
                viewModel.sendPushNotificationContinuation?.resume(returning: true)
            }
        }
        .actionSnackbar(
            action: $viewModel.deleteAbmeldungenState,
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
            action: $viewModel.deleteAllAbmeldungenState,
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
            action: $viewModel.sendPushNotificationState,
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

private struct StufenbereichContentView: View {
    
    private let stufe: SeesturmStufe
    private let abmeldungenState: UiState<[GoogleCalendarEventWithAnAbmeldungen]>
    private let deleteAllAbmeldungenState: ActionState<Void>
    private let onGetAktivitaetenRetry: () -> Void
    private let selectedDate: Binding<Date>
    private let selectedAktivitaetInteraction: Binding<AktivitaetInteractionType>
    private let isEditButtonLoading: (GoogleCalendarEventWithAnAbmeldungen) -> Bool
    private let onSendPushNotification: (GoogleCalendarEventWithAnAbmeldungen) -> Void
    private let onDeleteAnAbmeldungenForAktivitaet: (GoogleCalendarEventWithAnAbmeldungen) -> Void
    private let onEditAktivitaet: (GoogleCalendarEventWithAnAbmeldungen) -> Void
    private let showDeleteAllAbmeldungenConfirmationDialog: Binding<Bool>
    
    init(
        stufe: SeesturmStufe,
        abmeldungenState: UiState<[GoogleCalendarEventWithAnAbmeldungen]>,
        deleteAllAbmeldungenState: ActionState<Void>,
        onGetAktivitaetenRetry: @escaping () -> Void,
        selectedDate: Binding<Date>,
        selectedAktivitaetInteraction: Binding<AktivitaetInteractionType>,
        isEditButtonLoading: @escaping (GoogleCalendarEventWithAnAbmeldungen) -> Bool,
        onSendPushNotification: @escaping (GoogleCalendarEventWithAnAbmeldungen) -> Void,
        onDeleteAnAbmeldungenForAktivitaet: @escaping (GoogleCalendarEventWithAnAbmeldungen) -> Void,
        onEditAktivitaet: @escaping (GoogleCalendarEventWithAnAbmeldungen) -> Void,
        showDeleteAllAbmeldungenConfirmationDialog: Binding<Bool>
    ) {
        self.stufe = stufe
        self.abmeldungenState = abmeldungenState
        self.deleteAllAbmeldungenState = deleteAllAbmeldungenState
        self.onGetAktivitaetenRetry = onGetAktivitaetenRetry
        self.selectedDate = selectedDate
        self.selectedAktivitaetInteraction = selectedAktivitaetInteraction
        self.isEditButtonLoading = isEditButtonLoading
        self.onSendPushNotification = onSendPushNotification
        self.onDeleteAnAbmeldungenForAktivitaet = onDeleteAnAbmeldungenForAktivitaet
        self.onEditAktivitaet = onEditAktivitaet
        self.showDeleteAllAbmeldungenConfirmationDialog = showDeleteAllAbmeldungenConfirmationDialog
    }
    
    var body: some View {
        List {
            Section {
                
            } header: {
                VStack(alignment: .trailing, spacing: 8) {
                    DatePicker(
                        "Aktivitäten ab",
                        selection: selectedDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                    .tint(Color.SEESTURM_GREEN)
                    .disabled(!abmeldungenState.isSuccess)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.secondary)
                    if (stufe.allowedAktivitaetInteractions.count > 1) {
                        Picker("An-/Abmeldung", selection: selectedAktivitaetInteraction) {
                            ForEach(stufe.allowedAktivitaetInteractions) { interaction in
                                Label(interaction.nomenMehrzahl, systemImage: interaction.icon)
                                    .labelStyle(.titleAndIcon)
                                    .tag(interaction)
                                    .tint(interaction.color)
                            }
                        }
                        .disabled(!abmeldungenState.isSuccess)
                        .tint(selectedAktivitaetInteraction.wrappedValue.color)
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical)
            }
            switch abmeldungenState {
            case .loading(_):
                ForEach(0..<6) { index in
                    StufenbereichAnAbmeldungLoadingCell()
                        .padding(.top, index == 0 ? 16 : 0)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onGetAktivitaetenRetry)
                )
                .padding(.top)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .success(let data):
                let aktivitaeten = data.filter { $0.event.end >= selectedDate.wrappedValue }.sorted { $0.event.start > $1.event.start }
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
                    ForEach(aktivitaeten.groupesByMonthAndYear, id: \.0) { startDate, events in
                        let title = DateTimeUtil.shared.formatDate(
                            date: startDate,
                            format: "MMMM yyyy",
                            timeZone: TimeZone(identifier: "Europe/Zurich")!,
                            type: .absolute
                        )
                        Section {
                            ForEach(Array(events.enumerated()), id: \.element.event.id) { index, event in
                                StufenbereichAnAbmeldungCell(
                                    aktivitaet: event,
                                    stufe: stufe,
                                    selectedAktivitaetInteraction: selectedAktivitaetInteraction,
                                    isBearbeitenButtonLoading: isEditButtonLoading(event),
                                    onSendPushNotification: {
                                        onSendPushNotification(event)
                                    },
                                    onDeleteAnAbmeldungen: {
                                        onDeleteAnAbmeldungenForAktivitaet(event)
                                    },
                                    onEditAktivitaet: {
                                        onEditAktivitaet(event)
                                    },
                                    displayNavigationDestination: AccountNavigationDestination.displayAktivitaet(
                                        stufe: stufe,
                                        aktivitaet: event.event,
                                        type: .display
                                    )
                                )
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        } header: {
                            Text(title)
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.secondary)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .navigationTitle(stufe.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .listStyle(.plain)
        .scrollDisabled(abmeldungenState.scrollingDisabled)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if abmeldungenState.isSuccess {
                    if deleteAllAbmeldungenState.isLoading {
                        SeesturmProgressView(
                            color: .SEESTURM_GREEN
                        )
                    }
                    else {
                        Button {
                            withAnimation {
                                showDeleteAllAbmeldungenConfirmationDialog.wrappedValue = true
                            }
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(Color.SEESTURM_GREEN)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(
                    value: AccountNavigationDestination.aktivitaetBearbeiten(mode: .insert, stufe: stufe),
                    label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
                )
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        StufenbereichContentView(
            stufe: .biber,
            abmeldungenState: .loading(subState: .loading),
            deleteAllAbmeldungenState: .loading(action: ()),
            onGetAktivitaetenRetry: {},
            selectedDate: .constant(Date()),
            selectedAktivitaetInteraction: .constant(.abmelden),
            isEditButtonLoading: { _ in false },
            onSendPushNotification: { _ in },
            onDeleteAnAbmeldungenForAktivitaet: { _ in },
            onEditAktivitaet: { _ in },
            showDeleteAllAbmeldungenConfirmationDialog: .constant(false)
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        StufenbereichContentView(
            stufe: .biber,
            abmeldungenState: .error(message: "Schwerer Fehler"),
            deleteAllAbmeldungenState: .idle,
            onGetAktivitaetenRetry: {},
            selectedDate: .constant(Date()),
            selectedAktivitaetInteraction: .constant(.abmelden),
            isEditButtonLoading: { _ in false },
            onSendPushNotification: { _ in },
            onDeleteAnAbmeldungenForAktivitaet: { _ in },
            onEditAktivitaet: { _ in },
            showDeleteAllAbmeldungenConfirmationDialog: .constant(false)
        )
    }
}
#Preview("Empty") {
    NavigationStack(path: .constant(NavigationPath())) {
        StufenbereichContentView(
            stufe: .biber,
            abmeldungenState: .success(data: []),
            deleteAllAbmeldungenState: .idle,
            onGetAktivitaetenRetry: {},
            selectedDate: .constant(Date()),
            selectedAktivitaetInteraction: .constant(.abmelden),
            isEditButtonLoading: { _ in false },
            onSendPushNotification: { _ in },
            onDeleteAnAbmeldungenForAktivitaet: { _ in },
            onEditAktivitaet: { _ in },
            showDeleteAllAbmeldungenConfirmationDialog: .constant(false)
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        StufenbereichContentView(
            stufe: .wolf,
            abmeldungenState: .success(data: [
                GoogleCalendarEventWithAnAbmeldungen(
                    event: DummyData.aktivitaet1,
                    anAbmeldungen: [DummyData.abmeldung1]
                ),
                GoogleCalendarEventWithAnAbmeldungen(
                    event: DummyData.aktivitaet2,
                    anAbmeldungen: [DummyData.abmeldung3]
                )
            ]),
            deleteAllAbmeldungenState: .loading(action: ()),
            onGetAktivitaetenRetry: {},
            selectedDate: .constant(DummyData.oldDate),
            selectedAktivitaetInteraction: .constant(.abmelden),
            isEditButtonLoading: { _ in false },
            onSendPushNotification: { _ in },
            onDeleteAnAbmeldungenForAktivitaet: { _ in },
            onEditAktivitaet: { _ in },
            showDeleteAllAbmeldungenConfirmationDialog: .constant(false)
        )
    }
}
