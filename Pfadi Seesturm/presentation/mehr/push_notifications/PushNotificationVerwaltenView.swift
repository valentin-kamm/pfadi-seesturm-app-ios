//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import FirebaseMessaging
import SwiftData

struct PushNotificationVerwaltenView<Header: View, Footer: View>: View {
    
    @State private var viewModel: PushNotificationVerwaltenViewModel
    private let additionalTopContent: () -> Header
    private let additionalBottomContent: () -> Footer
    
    init(
        viewModel: PushNotificationVerwaltenViewModel,
        @ViewBuilder additionalTopContent: @escaping () -> Header,
        @ViewBuilder additionalBottomContent: @escaping () -> Footer
    ) {
        self.viewModel = viewModel
        self.additionalTopContent = additionalTopContent
        self.additionalBottomContent = additionalBottomContent
    }
    
    init(
        viewModel: PushNotificationVerwaltenViewModel
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            viewModel: viewModel,
            additionalTopContent: { EmptyView() },
            additionalBottomContent: { EmptyView() }
        )
    }
    
    @Query private var topicsQuery: [SubscribedFCMNotificationTopicDao]
    private var subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]> {
        do {
            let topics = try topicsQuery.map { try $0.getTopic() }
            return .success(data: topics)
        }
        catch {
            return .error(message: "Abonnierte Push-Nachrichten konnten nicht ermittelt werden. Installiere die App neu, um den Fehler zu beheben.")
        }
    }
    
    var body: some View {
        PushNotificationVerwaltenContentView(
            subscribedTopicsState: subscribedTopicsState,
            actionState: viewModel.actionState,
            onToggle: { topic, isSwitchingOn in
                Task {
                    await viewModel.toggleTopic(topic: topic, isSwitchingOn: isSwitchingOn)
                }
            },
            additionalTopContent: additionalTopContent,
            additionalBottomContent: additionalBottomContent
        )
        .alert(
            "Push-Nachrichten nicht aktiviert",
            isPresented: $viewModel.showSettingsAlert,
            actions: {
                Button("Einstellungen") {
                    viewModel.goToAppSettings()
                }
                Button("OK", role: .cancel) {}
            },
            message: {
                Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        )
        .actionSnackbar(
            action: $viewModel.actionState,
            events: [
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ],
            defaultErrorMessage: "Beim Bearbeiten von Push-Nachrichten ist ein unbekannter Fehler aufgetreten."
        )
    }
}

struct PushNotificationVerwaltenContentView<Header: View, Footer: View>: View {
    
    private let subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]>
    private let actionState: ActionState<SeesturmFCMNotificationTopic>
    private let onToggle: (SeesturmFCMNotificationTopic, Bool) -> Void
    private let additionalTopContent: () -> Header
    private let additionalBottomContent: () -> Footer
    
    init(
        subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]>,
        actionState: ActionState<SeesturmFCMNotificationTopic>,
        onToggle: @escaping (SeesturmFCMNotificationTopic, Bool) -> Void,
        @ViewBuilder additionalTopContent: @escaping () -> Header,
        @ViewBuilder additionalBottomContent: @escaping () -> Footer
    ) {
        self.subscribedTopicsState = subscribedTopicsState
        self.actionState = actionState
        self.onToggle = onToggle
        self.additionalTopContent = additionalTopContent
        self.additionalBottomContent = additionalBottomContent
    }
    
    init(
        subscribedTopicsState: UiState<[SeesturmFCMNotificationTopic]>,
        actionState: ActionState<SeesturmFCMNotificationTopic>,
        onToggle: @escaping (SeesturmFCMNotificationTopic, Bool) -> Void
    ) where Header == EmptyView, Footer == EmptyView {
        self.init(
            subscribedTopicsState: subscribedTopicsState,
            actionState: actionState,
            onToggle: onToggle,
            additionalTopContent: { EmptyView() },
            additionalBottomContent: { EmptyView() }
        )
    }
    
    private let sections: [FormSection: [Int: SeesturmFCMNotificationTopic]] = [
        FormSection(
            header: "Aktuell",
            footer: "Erhalte eine Benachrichtigung wenn ein neuer Post veröffentlicht wird",
            order: 1
        ): [1: .aktuell],
        FormSection(
            header: "Nächste Aktivität",
            footer: "Erhalte eine Benachrichtigung wenn die Infos zur nächsten Aktivität veröffentlicht werden",
            order: 2
        ): [1: .biberAktivitaeten,
            2: .wolfAktivitaeten,
            3: .pfadiAktivitaeten,
            4: .pioAktivitaeten]
    ]
    
    var body: some View {
        Form {
            
            additionalTopContent()
            
            switch subscribedTopicsState {
            case .loading(_):
                EmptyView()
            case .error(let message):
                ContentUnavailableView(
                    label: {
                        Label("Ein Fehler ist aufgetreten", systemImage: "exclamationmark.bubble")
                    },
                    description: {
                        Text(message)
                    }
                )
            case .success(let data):
                ForEach(Array(sections.keys).sorted(by: { $0.order < $1.order })) { section in
                    let sortedTopics = sections[section]!.sorted(by: { $0.key < $1.key }).map { $0.value }
                    Section {
                        ForEach(Array(sortedTopics)) { topic in
                            PushNotificationToggle(
                                topic: topic,
                                state: actionState,
                                isOn: data.contains(topic),
                                onToggle: { newValue in
                                    onToggle(topic, newValue)
                                }
                            )
                        }
                    } header: {
                        Text(section.header)
                    } footer: {
                        Text(section.footer)
                    }
                }
            }
            
            additionalBottomContent()
        }
        .navigationTitle("Push-Nachrichten")
        .navigationBarTitleDisplayMode(.inline)
        .formStyle(.automatic)
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        PushNotificationVerwaltenContentView(
            subscribedTopicsState: .loading(subState: .loading),
            actionState: .idle,
            onToggle: { _, _ in }
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        PushNotificationVerwaltenContentView(
            subscribedTopicsState: .error(message: "Schwerer Fehler"),
            actionState: .idle,
            onToggle: { _, _ in }
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        PushNotificationVerwaltenContentView(
            subscribedTopicsState: .success(data: [.wolfAktivitaeten]),
            actionState: .loading(action: .biberAktivitaeten),
            onToggle: { _, _ in }
        )
    }
}
