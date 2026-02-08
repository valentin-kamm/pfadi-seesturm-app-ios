//
//  ManageEventView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.01.2026.
//
import SwiftUI

struct ManageEventView: View {
    
    @Environment(\.accountModule) private var accountModule: AccountModule
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    
    private let eventType: EventToManageType
    
    init(
        eventType: EventToManageType
    ) {
        self.eventType = eventType
    }
    
    var body: some View {
        switch eventType {
        case .aktivitaet(let stufe, _):
            ManageEventDIView(
                viewModel: ManageEventViewModel(
                    eventType: eventType,
                    controller: ManageAktivitaetController(
                        service: accountModule.stufenbereichService,
                        stufe: stufe
                    )
                )
            )
        case .multipleAktivitaeten:
            ManageEventDIView(
                viewModel: ManageEventViewModel(
                    eventType: eventType,
                    controller: ManageAktivitaetenController(
                        service: accountModule.stufenbereichService
                    )
                )
            )
        case .termin(let calendar, _):
            ManageEventDIView(
                viewModel: ManageEventViewModel(
                    eventType: eventType,
                    controller: ManageTerminController(
                        service: wordpressModule.anlaesseService,
                        calendar: calendar
                    )
                )
            )
        }
    }
}

private struct ManageEventDIView<C: EventManagementController>: View {
    
    @State private var viewModel: ManageEventViewModel<C>
    
    init(
        viewModel: ManageEventViewModel<C>
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ManageEventContentView(
            eventType: viewModel.eventType,
            mode: viewModel.mode,
            eventState: viewModel.eventState,
            publishEventState: viewModel.publishEventState,
            start: $viewModel.start,
            end: $viewModel.end,
            isAllDay: $viewModel.isAllDay,
            location: $viewModel.location,
            title: $viewModel.title,
            description: $viewModel.description,
            eventForPreview: viewModel.eventForPreview,
            pushNotificationBinding: viewModel.pushNotificationBinding,
            selectedStufen: viewModel.selectedStufenBinding,
            showConfirmationDialog: $viewModel.showConfirmationDialog,
            confirmationDialogTitle: viewModel.confirmationDialogTitle,
            confirmationDialogConfirmButtonText: viewModel.confirmationDialogConfirmButtonText,
            onEventRetry: {
                await viewModel.fetchEventIfPossible()
            },
            onShowTemplateSheet: viewModel.onShowTemplatesSheet,
            onShowPreviewSheet: {
                viewModel.showPreviewSheet = true
            },
            onTrySubmit: viewModel.trySubmit,
            onSubmit: {
                Task {
                    await viewModel.submit()
                }
            }
        )
        .task {
            await viewModel.fetchEventIfPossible()
            await viewModel.observeTemplatesIfPossible()
        }
        .actionSnackbar(
            action: $viewModel.publishEventState,
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
        .sheet(isPresented: viewModel.showTemplatesSheet ?? .constant(false)) {
            if let ts = viewModel.templatesState {
                NavigationStack(path: .constant(NavigationPath())) {
                    TemplateListView(
                        state: ts,
                        mode: .use,
                        navigationTitle: viewModel.eventType.templatesNavigationTitle,
                        onElementClick: { template in
                            viewModel.useTemplateIfPossible(template)
                        }
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .sheet(item: viewModel.previewSheetItem) { previewEvent in
            NavigationStack(path: .constant(NavigationPath())) {
                ManageEventPreviewView(
                    type: viewModel.eventPreviewType,
                    event: previewEvent
                )
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
            }
        }
    }
}

private struct ManageEventContentView: View {
    
    private let eventType: EventToManageType
    private let mode: EventManagementMode
    private let eventState: UiState<Void>
    private let publishEventState: ActionState<Void>
    private let start: Binding<Date>
    private let end: Binding<Date>
    private let isAllDay: Binding<Bool>
    private let location: Binding<String>
    private let title: Binding<String>
    private let description: Binding<String>
    private let eventForPreview: GoogleCalendarEvent?
    private let pushNotificationBinding: Binding<Bool>?
    private let selectedStufen: Binding<Set<SeesturmStufe>>?
    private let showConfirmationDialog: Binding<Bool>
    private let confirmationDialogTitle: String
    private let confirmationDialogConfirmButtonText: String
    private let onEventRetry: () async -> Void
    private let onShowTemplateSheet: (() -> Void)?
    private let onShowPreviewSheet: () -> Void
    private let onTrySubmit: () -> Void
    private let onSubmit: () -> Void
    
    init(
        eventType: EventToManageType,
        mode: EventManagementMode,
        eventState: UiState<Void>,
        publishEventState: ActionState<Void>,
        start: Binding<Date>,
        end: Binding<Date>,
        isAllDay: Binding<Bool>,
        location: Binding<String>,
        title: Binding<String>,
        description: Binding<String>,
        eventForPreview: GoogleCalendarEvent?,
        pushNotificationBinding: Binding<Bool>?,
        selectedStufen: Binding<Set<SeesturmStufe>>?,
        showConfirmationDialog: Binding<Bool>,
        confirmationDialogTitle: String,
        confirmationDialogConfirmButtonText: String,
        onEventRetry: @escaping () async -> Void,
        onShowTemplateSheet: (() -> Void)?,
        onShowPreviewSheet: @escaping () -> Void,
        onTrySubmit: @escaping () -> Void,
        onSubmit: @escaping () -> Void
    ) {
        self.eventType = eventType
        self.mode = mode
        self.eventState = eventState
        self.publishEventState = publishEventState
        self.start = start
        self.end = end
        self.isAllDay = isAllDay
        self.location = location
        self.title = title
        self.description = description
        self.eventForPreview = eventForPreview
        self.pushNotificationBinding = pushNotificationBinding
        self.selectedStufen = selectedStufen
        self.showConfirmationDialog = showConfirmationDialog
        self.confirmationDialogTitle = confirmationDialogTitle
        self.confirmationDialogConfirmButtonText = confirmationDialogConfirmButtonText
        self.onEventRetry = onEventRetry
        self.onShowTemplateSheet = onShowTemplateSheet
        self.onShowPreviewSheet = onShowPreviewSheet
        self.onTrySubmit = onTrySubmit
        self.onSubmit = onSubmit
    }
    
    private enum AktivitaetBearbeitenFormFields: String, FocusControlItem {
        case treffpunkt
        case titel
        case beschreibung
        var id: AktivitaetBearbeitenFormFields { self }
    }
    
    var body: some View {
        FocusControlView(allFields: AktivitaetBearbeitenFormFields.allCases) { focused in
            List {
                switch eventState {
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .async(action: onEventRetry)
                    )
                    .padding(.top)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                case .loading(_), .success(_):
                    Group {
                        Section {
                            DatePicker("Start", selection: start, displayedComponents: isAllDay.wrappedValue ? [.date] : [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(eventType.accentColor)
                                .environment(\.timeZone, TimeZone(identifier: "Europe/Zurich")!)
                            DatePicker("Ende", selection: end, displayedComponents: isAllDay.wrappedValue ? [.date] : [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .tint(eventType.accentColor)
                                .environment(\.timeZone, TimeZone(identifier: "Europe/Zurich")!)
                            Toggle("Ganztägig", isOn: isAllDay)
                                .tint(eventType.accentColor)
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
                                    .focused(focused, equals: .treffpunkt)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focused.wrappedValue = .titel
                                    }
                            }
                        } footer: {
                            switch eventType {
                            case .aktivitaet(_, _), .multipleAktivitaeten:
                                Text("Treffpunkt am Anfang der Aktivität")
                            case .termin(_, _):
                                Text("Treffpunkt am Anfang des Anlasses")
                            }
                        }
                        
                        Section {
                            HStack(spacing: 16) {
                                Text("Titel")
                                TextField(eventType.titlePlaceholder, text: title)
                                    .multilineTextAlignment(.trailing)
                                    .textFieldStyle(.roundedBorder)
                                    .focused(focused, equals: .titel)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focused.wrappedValue = .beschreibung
                                    }
                            }
                            SeesturmHTMLEditor(
                                html: description,
                                scrollable: true,
                                disabled: eventState.isLoading || publishEventState.isLoading,
                                buttonTint: eventType.accentColor
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .focused(focused, equals: .beschreibung)
                            if let showSheet = onShowTemplateSheet {
                                Button("Vorlage einfügen") {
                                    showSheet()
                                }
                                .foregroundStyle(Color.primary)
                            }
                        } header: {
                            Text("Beschreibung")
                        }
                        
                        if let binding = selectedStufen {
                            Section {
                                ForEach(SeesturmStufe.allCases.sorted { $0.id < $1.id }) { stufe in
                                    Button {
                                        if binding.wrappedValue.contains(stufe) {
                                            guard binding.wrappedValue.count > 1 else {
                                                return
                                            }
                                            binding.wrappedValue.remove(stufe)
                                        }
                                        else {
                                            binding.wrappedValue.insert(stufe)
                                        }
                                    } label: {
                                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                                            Text(stufe.name)
                                                .foregroundStyle(Color.primary)
                                            Spacer()
                                            if binding.wrappedValue.contains(stufe) {
                                                Image(systemName: "checkmark")
                                                    .foregroundStyle(eventType.accentColor)
                                            }
                                        }
                                    }
                                    
                                }
                            } header: {
                                Text("Stufen auswählen")
                            }
                        }
                        
                        Section {
                            if eventForPreview != nil {
                                Button("Vorschau") {
                                    onShowPreviewSheet()
                                }
                                .foregroundStyle(Color.primary)
                            }
                            if let binding = pushNotificationBinding {
                                Toggle("Push-Nachricht senden", isOn: binding)
                                    .tint(eventType.accentColor)
                            }
                        } header: {
                            Text(mode.nomen)
                        }
                        
                        Section {
                            SeesturmButton(
                                type: .primary,
                                action: .sync(action: onTrySubmit),
                                title: mode.nomen,
                                colors: .custom(contentColor: eventType.onAccentColor, buttonColor: eventType.accentColor),
                                isLoading: publishEventState.isLoading,
                                disabled: eventState.isLoading || publishEventState.isLoading
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .confirmationDialog(
                                confirmationDialogTitle,
                                isPresented: showConfirmationDialog,
                                titleVisibility: .visible
                            ) {
                                Button("Abbrechen", role: .cancel) { }
                                Button(confirmationDialogConfirmButtonText, role: .destructive) {
                                    onSubmit()
                                }
                            }
                        }
                    }
                    .disabled(eventState.isLoading || publishEventState.isLoading)
                }
            }
            .navigationTitle(eventType.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
            .scrollDisabled(eventState.scrollingDisabled)
            .toolbar {
                if case .aktivitaet(let stufe, _) = eventType {
                    NavigationLink(value: AccountNavigationDestination.templates(stufe: stufe)) {
                        Text("Vorlagen")
                    }
                }
            }
            .dynamicListStyle(isListPlain: eventState.isError)
            .overlay {
                if case .loading(_) = eventState {
                    VStack(alignment: .center, spacing: 16) {
                        SeesturmProgressView(size: 32, color: eventType.accentColor)
                        Group {
                            switch eventType {
                            case .aktivitaet(let stufe, _):
                                Text("\(stufe.aktivitaetDescription) wird geladen...")
                            case .multipleAktivitaeten:
                                Text("Aktivität wird geladen...")
                            case .termin(_, _):
                                Text("Anlass wird geladen...")
                            }
                        }
                        .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(.ultraThinMaterial)
                }
            }
        }
    }
}

private struct ManageEventContentViewForPreview: View {
    
    enum PreviewState {
        case error
        case success
        case loadingEvent
        case publishing
    }
    
    private let state: PreviewState
    private let type: EventToManageType
    
    init(
        state: PreviewState,
        type: EventToManageType
    ) {
        self.state = state
        self.type = type
    }
    
    private var mode: EventManagementMode {
        switch type {
        case .aktivitaet(_, let mode):
            return mode
        case .multipleAktivitaeten:
            return .insert
        case .termin(_, let mode):
            return mode
        }
    }
    
    private var uiState: UiState<Void> {
        switch state {
        case .error:
            .error(message: "Schwerer Fehler")
        case .success:
            .success(data: ())
        case .loadingEvent:
            .loading(subState: .loading)
        case .publishing:
            .success(data: ())
        }
    }
    
    private var actionState: ActionState<Void> {
        switch state {
        case .error, .success, .loadingEvent:
            .idle
        case .publishing:
            .loading(action: ())
        }
    }
    
    private var pushNotificationBinding: Binding<Bool>? {
        switch type {
        case .aktivitaet(_, _), .multipleAktivitaeten:
            .constant(true)
        case .termin(_, _):
            nil
        }
    }
    
    private var selectedStufen: Binding<Set<SeesturmStufe>>? {
        switch type {
        case .multipleAktivitaeten:
            .constant(Set([.wolf, .pio]))
        case .termin(_, _), .aktivitaet(_, _):
            nil
        }
    }
    
    private var showTemplateSheet: (() -> Void)? {
        switch type {
        case .aktivitaet(_, _), .multipleAktivitaeten:
            {}
        case .termin(_, _):
            nil
        }
    }
    
    var body: some View {
        NavigationStack {
            ManageEventContentView(
                eventType: type,
                mode: mode,
                eventState: uiState,
                publishEventState: actionState,
                start: .constant(Date()),
                end: .constant(Date()),
                isAllDay: .constant(false),
                location: .constant(""),
                title: .constant(""),
                description: .constant(""),
                eventForPreview: DummyData.aktivitaet1,
                pushNotificationBinding: pushNotificationBinding,
                selectedStufen: selectedStufen,
                showConfirmationDialog: .constant(false),
                confirmationDialogTitle: "",
                confirmationDialogConfirmButtonText: "",
                onEventRetry: {},
                onShowTemplateSheet: showTemplateSheet,
                onShowPreviewSheet: {},
                onTrySubmit: {},
                onSubmit: {}
            )
        }
    }
}

#Preview("Aktivität (Laden)") {
    ManageEventContentViewForPreview(
        state: .loadingEvent,
        type: .aktivitaet(stufe: .wolf, mode: .update(eventId: ""))
    )
}
#Preview("Aktivität (Fehler)") {
    ManageEventContentViewForPreview(
        state: .error,
        type: .aktivitaet(stufe: .wolf, mode: .insert)
    )
}
#Preview("Aktivität (Erfolg)") {
    ManageEventContentViewForPreview(
        state: .success,
        type: .aktivitaet(stufe: .wolf, mode: .insert)
    )
}
#Preview("Aktivität (Veröffentlichen)") {
    ManageEventContentViewForPreview(
        state: .publishing,
        type: .aktivitaet(stufe: .wolf, mode: .update(eventId: ""))
    )
}
#Preview("Aktivitäten (Laden)") {
    ManageEventContentViewForPreview(
        state: .loadingEvent,
        type: .multipleAktivitaeten
    )
}
#Preview("Aktivitäten (Fehler)") {
    ManageEventContentViewForPreview(
        state: .error,
        type: .multipleAktivitaeten
    )
}
#Preview("Aktivitäten (Erfolg)") {
    ManageEventContentViewForPreview(
        state: .success,
        type: .multipleAktivitaeten
    )
}
#Preview("Aktivitäten (Veröffentlichen)") {
    ManageEventContentViewForPreview(
        state: .publishing,
        type: .multipleAktivitaeten
    )
}
#Preview("Termin (Laden)") {
    ManageEventContentViewForPreview(
        state: .loadingEvent,
        type: .termin(calendar: .termine, mode: .update(eventId: ""))
    )
}
#Preview("Termin (Fehler)") {
    ManageEventContentViewForPreview(
        state: .error,
        type: .termin(calendar: .termineLeitungsteam, mode: .insert)
    )
}
#Preview("Termin (Erfolg)") {
    ManageEventContentViewForPreview(
        state: .success,
        type: .termin(calendar: .termineLeitungsteam, mode: .update(eventId: ""))
    )
}
#Preview("Termin (Veröffentlichen)") {
    ManageEventContentViewForPreview(
        state: .publishing,
        type: .termin(calendar: .termine, mode: .insert)
    )
}
