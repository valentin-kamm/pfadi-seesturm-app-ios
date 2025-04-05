//
//  AktivitätBearbeitenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct AktivitaetBearbeitenView: View {
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @StateObject var viewModel: AktivitaetBearbeitenViewModel
    let stufe: SeesturmStufe
    
    @State private var navigationPath: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                switch viewModel.state.aktivitaetState {
                case .loading(_):
                    Section {
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(1)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(1)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    } header: {
                        Text("Zeit")
                            .redacted(reason: .placeholder)
                    } footer: {
                        Text("Zeiten in MEZ/MESZ (CH-Zeit)")
                            .redacted(reason: .placeholder)
                    }
                    Section {
                        Text("Treffpunkt")
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    } footer: {
                        Text("Treffpunkt am Anfang der Aktivität")
                            .redacted(reason: .placeholder)
                    }
                    Section {
                        Text("Titel")
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(5)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    } header: {
                        Text("Beschreibung")
                            .redacted(reason: .placeholder)
                    }
                    Section {
                        Text("Push-Nachricht senden")
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                        Text("Vorschau")
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    } header: {
                        Text("Veröffentlichen")
                            .redacted(reason: .placeholder)
                    }
                case .error(let message):
                    CardErrorView(
                        errorDescription: message,
                        asyncRetryAction: {
                            await viewModel.fetchAktivitaetIfNecessary()
                        }
                    )
                    .padding(.vertical)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                case .success(_):
                    Section {
                        DatePicker("Start", selection: viewModel.startBinding, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .disabled(viewModel.state.publishAktivitaetState.isLoading)
                            .tint(Color.SEESTURM_GREEN)
                        DatePicker("Ende", selection: viewModel.endBinding, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .disabled(viewModel.state.publishAktivitaetState.isLoading)
                            .tint(Color.SEESTURM_GREEN)
                        
                    } header: {
                        Text("Zeit")
                    } footer: {
                        Text("Zeiten in MEZ/MESZ (CH-Zeit)")
                    }
                    
                    Section {
                        HStack(spacing: 16) {
                            Text("Treffpunkt")
                            TextField("Ort", text: viewModel.locationBinding)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.roundedBorder)
                                .disabled(viewModel.state.publishAktivitaetState.isLoading)
                        }
                    } footer: {
                        Text("Treffpunkt am Anfang der Aktivität")
                    }
                    
                    Section {
                        HStack(spacing: 16) {
                            Text("Titel")
                            TextField(stufe.aktivitaetDescription, text: viewModel.titleBinding)
                                .multilineTextAlignment(.trailing)
                                .textFieldStyle(.roundedBorder)
                                .disabled(viewModel.state.publishAktivitaetState.isLoading)
                        }
                        SeesturmHTMLEditor(
                            html: viewModel.descriptionBinding,
                            scrollable: true,
                            disabled: viewModel.state.publishAktivitaetState.isLoading
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        /*
                        RichHTMLEditor(html: viewModel.descriptionBinding, textAttributes: textAttributes)
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .disabled(viewModel.state.publishAktivitaetState.isLoading)
                         */
                    } header: {
                        Text("Beschreibung")
                    }
                    
                    Section {
                        Toggle("Push-Nachricht senden", isOn: viewModel.sendPushNotificationBinding)
                            .tint(stufe.highContrastColor)
                            .disabled(viewModel.state.publishAktivitaetState.isLoading)
                        if let aktivitaet = viewModel.aktivitaetForPreview {
                            NavigationLink(value: AktivitaetBearbeitenNavigationDestination.preview(aktivitaet: aktivitaet)) {
                                Text("Vorschau")
                            }
                        }
                    } header: {
                        Text("Veröffentlichen")
                    }
                    
                    Section {
                        SeesturmButton(
                            style: .primary,
                            action: .sync(action: {
                                viewModel.trySubmit()
                            }),
                            title: viewModel.buttonTitle,
                            colors: .custom(contentColor: .white, buttonColor: stufe.highContrastColor),
                            isLoading: viewModel.state.publishAktivitaetState.isLoading,
                            isDisabled: viewModel.state.publishAktivitaetState.isLoading
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
            .myListStyle(isListPlain: viewModel.state.aktivitaetState.isError)
            .task {
                await viewModel.fetchAktivitaetIfNecessary()
            }
            .navigationDestination(for: AktivitaetBearbeitenNavigationDestination.self) { destination in
                switch destination {
                case .preview(let aktivitaet):
                    AktivitaetDetailView(
                        viewModel: AktivitaetDetailViewModel(
                            service: wordpressModule.naechsteAktivitaetService,
                            input: .object(object: aktivitaet),
                            stufe: stufe,
                            userId: nil
                        ),
                        stufe: stufe,
                        isPreview: true
                    )
                }
            }
        }
        .actionSnackbar(
            action: viewModel.publishAktivitaetStateBinding,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .confirmationDialog(
            viewModel.confirmationDialogTitle,
            isPresented: viewModel.showConfirmationDialogBinding,
            titleVisibility: .visible
        ) {
            Button("Abbrechen", role: .cancel) {
                // do nothing
            }
            Button(viewModel.confirmationDialogConfirmButtonText, role: .destructive) {
                Task {
                    await viewModel.submit()
                }
            }
        }
    }
}

enum AktivitaetBearbeitenNavigationDestination: NavigationDestination {
    case preview(aktivitaet: GoogleCalendarEvent)
}

#Preview {
    AktivitaetBearbeitenView(
        viewModel: AktivitaetBearbeitenViewModel(
            selectedSheetMode: .insert,
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
            stufe: .pio,
            onPublishAktivitaetStateChange: { _ in },
            onDismiss: {}
        ),
        stufe: .pio
    )
}
