//
//  AktivitätBearbeitenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct AktivitaetBearbeitenView: View {
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    
    @State private var viewModel: AktivitaetBearbeitenViewModel
    private let mode: AktivitaetBearbeitenMode
    private let stufe: SeesturmStufe
    
    init(
        viewModel: AktivitaetBearbeitenViewModel,
        mode: AktivitaetBearbeitenMode,
        stufe: SeesturmStufe
    ) {
        self.viewModel = viewModel
        self.mode = mode
        self.stufe = stufe
    }
        
    var body: some View {
        AktivitaetBearbeitenContentView(
            mode: mode,
            stufe: stufe,
            aktivitaetState: viewModel.aktivitaetState,
            publishAktivitaetState: viewModel.publishAktivitaetState,
            onReadAktivitaetRetry: viewModel.fetchAktivitaetIfNecessary,
            start: $viewModel.start,
            end: $viewModel.end,
            location: $viewModel.location,
            sendPushNotification: $viewModel.sendPushNotification,
            title: $viewModel.title,
            description: $viewModel.description,
            aktivitaetForPreview: viewModel.aktivitaetForPreview,
            onSubmit: viewModel.trySubmit,
            onShowPreviewSheet: {
                withAnimation {
                    viewModel.showPreviewSheet = true
                }
            },
            onShowTemplatesSheet: {
                withAnimation {
                    viewModel.showTemplatesSheet = true
                }
            }
        )
        .task {
            await viewModel.fetchAktivitaetIfNecessary()
            await viewModel.observeTemplates()
        }
        .actionSnackbar(
            action: $viewModel.publishAktivitaetState,
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
        .confirmationDialog(
            viewModel.confirmationDialogTitle,
            isPresented: $viewModel.showConfirmationDialog,
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
        .sheet(isPresented: viewModel.previewSheetBinding) {
            NavigationStack(path: .constant(NavigationPath())) {
                if let aktivitaet = viewModel.aktivitaetForPreview {
                    AktivitaetDetailView(
                        viewModel: AktivitaetDetailViewModel(
                            input: .object(object: aktivitaet),
                            service: wordpressModule.naechsteAktivitaetService,
                            stufe: stufe,
                            userId: nil
                        ),
                        stufe: stufe,
                        type: .preview
                    )
                    .navigationTitle("Vorschau \(stufe.aktivitaetDescription)")
                }
                else {
                    EmptyView()
                }
            }
            .presentationDetents([.medium, .large])
            .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $viewModel.showTemplatesSheet) {
            NavigationStack(path: .constant(NavigationPath())) {
                TemplateListView(
                    state: viewModel.templatesState,
                    stufe: stufe,
                    mode: .use,
                    onElementClick: { template in
                        viewModel.useTemplate(template)
                    }
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct AktivitaetBearbeitenContentView: View {
    
    private let mode: AktivitaetBearbeitenMode
    private let stufe: SeesturmStufe
    private let aktivitaetState: UiState<Void>
    private let publishAktivitaetState: ActionState<Void>
    private let onReadAktivitaetRetry: () async -> Void
    private let start: Binding<Date>
    private let end: Binding<Date>
    private let location: Binding<String>
    private let sendPushNotification: Binding<Bool>
    private let title: Binding<String>
    private let description: Binding<String>
    private let aktivitaetForPreview: GoogleCalendarEvent?
    private let onSubmit: () -> Void
    private let onShowPreviewSheet: () -> Void
    private let onShowTemplatesSheet: () -> Void
    
    init(
        mode: AktivitaetBearbeitenMode,
        stufe: SeesturmStufe,
        aktivitaetState: UiState<Void>,
        publishAktivitaetState: ActionState<Void>,
        onReadAktivitaetRetry: @escaping () async -> Void,
        start: Binding<Date>,
        end: Binding<Date>,
        location: Binding<String>,
        sendPushNotification: Binding<Bool>,
        title: Binding<String>,
        description: Binding<String>,
        aktivitaetForPreview: GoogleCalendarEvent?,
        onSubmit: @escaping () -> Void,
        onShowPreviewSheet: @escaping () -> Void,
        onShowTemplatesSheet: @escaping () -> Void
    ) {
        self.mode = mode
        self.stufe = stufe
        self.aktivitaetState = aktivitaetState
        self.publishAktivitaetState = publishAktivitaetState
        self.onReadAktivitaetRetry = onReadAktivitaetRetry
        self.start = start
        self.end = end
        self.location = location
        self.sendPushNotification = sendPushNotification
        self.title = title
        self.description = description
        self.aktivitaetForPreview = aktivitaetForPreview
        self.onSubmit = onSubmit
        self.onShowPreviewSheet = onShowPreviewSheet
        self.onShowTemplatesSheet = onShowTemplatesSheet
    }
    
    var body: some View {
        List {
            switch aktivitaetState {
            case .loading(_):
                Section {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
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
                        .loadingBlinking()
                } footer: {
                    Text("Treffpunkt am Anfang der Aktivität")
                        .redacted(reason: .placeholder)
                }
                Section {
                    Text("Titel")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(5)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text("Vorlage einfügen")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                } header: {
                    Text("Beschreibung")
                        .redacted(reason: .placeholder)
                }
                Section {
                    Text("Vorschau")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text("Push-Nachricht senden")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                } header: {
                    Text("Veröffentlichen")
                        .redacted(reason: .placeholder)
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onReadAktivitaetRetry)
                )
                .padding(.top)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .success(_):
                Section {
                    DatePicker("Start", selection: start, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .disabled(publishAktivitaetState.isLoading)
                        .tint(Color.SEESTURM_GREEN)
                    DatePicker("Ende", selection: end, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .disabled(publishAktivitaetState.isLoading)
                        .tint(Color.SEESTURM_GREEN)
                    
                } header: {
                    Text("Zeit")
                } footer: {
                    Text("Zeiten in MEZ/MESZ (CH-Zeit)")
                }
                
                Section {
                    HStack(spacing: 16) {
                        Text("Treffpunkt")
                        TextField("Ort", text: location)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .disabled(publishAktivitaetState.isLoading)
                    }
                } footer: {
                    Text("Treffpunkt am Anfang der Aktivität")
                }
                
                Section {
                    HStack(spacing: 16) {
                        Text("Titel")
                        TextField(stufe.aktivitaetDescription, text: title)
                            .multilineTextAlignment(.trailing)
                            .textFieldStyle(.roundedBorder)
                            .disabled(publishAktivitaetState.isLoading)
                    }
                    SeesturmHTMLEditor(
                        html: description,
                        scrollable: true,
                        disabled: publishAktivitaetState.isLoading
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                    Button("Vorlage einfügen") {
                        onShowTemplatesSheet()
                    }
                    .foregroundStyle(Color.primary)
                    .disabled(publishAktivitaetState.isLoading)
                } header: {
                    Text("Beschreibung")
                }
                
                Section {
                    if aktivitaetForPreview != nil {
                        Button("Vorschau") {
                            onShowPreviewSheet()
                        }
                        .foregroundStyle(Color.primary)
                        .disabled(publishAktivitaetState.isLoading)
                    }
                    Toggle("Push-Nachricht senden", isOn: sendPushNotification)
                        .tint(stufe.highContrastColor)
                        .disabled(publishAktivitaetState.isLoading)
                } header: {
                    Text(mode.buttonTitle)
                }
                
                Section {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: onSubmit),
                        title: mode.buttonTitle,
                        colors: .custom(contentColor: .white, buttonColor: stufe.highContrastColor),
                        isLoading: publishAktivitaetState.isLoading,
                        disabled: publishAktivitaetState.isLoading
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
        .navigationTitle(mode.navigationTitle(for: stufe))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .scrollDisabled(aktivitaetState.scrollingDisabled)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AccountNavigationDestination.templates(stufe: stufe)) {
                    Text("Vorlagen")
                }
            }
        }
        .dynamicListStyle(isListPlain: aktivitaetState.isError)
    }
}

#Preview("Laden") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetBearbeitenContentView(
            mode: .insert,
            stufe: .biber,
            aktivitaetState: .loading(subState: .loading),
            publishAktivitaetState: .idle,
            onReadAktivitaetRetry: {},
            start: .constant(Date()),
            end: .constant(Date()),
            location: .constant(""),
            sendPushNotification: .constant(false),
            title: .constant(""),
            description: .constant(""),
            aktivitaetForPreview: nil,
            onSubmit: {},
            onShowPreviewSheet: {},
            onShowTemplatesSheet: {}
        )
    }
}
#Preview("Fehler") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetBearbeitenContentView(
            mode: .insert,
            stufe: .wolf,
            aktivitaetState: .error(message: "Schwerer Fehler"),
            publishAktivitaetState: .idle,
            onReadAktivitaetRetry: {},
            start: .constant(Date()),
            end: .constant(Date()),
            location: .constant(""),
            sendPushNotification: .constant(false),
            title: .constant(""),
            description: .constant(""),
            aktivitaetForPreview: nil,
            onSubmit: {},
            onShowPreviewSheet: {},
            onShowTemplatesSheet: {}
        )
    }
}
#Preview("Erfolg") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetBearbeitenContentView(
            mode: .insert,
            stufe: .pio,
            aktivitaetState: .success(data: ()),
            publishAktivitaetState: .idle,
            onReadAktivitaetRetry: {},
            start: .constant(Date()),
            end: .constant(Date()),
            location: .constant(""),
            sendPushNotification: .constant(false),
            title: .constant(""),
            description: .constant(""),
            aktivitaetForPreview: DummyData.aktivitaet1,
            onSubmit: {},
            onShowPreviewSheet: {},
            onShowTemplatesSheet: {}
        )
    }
}
