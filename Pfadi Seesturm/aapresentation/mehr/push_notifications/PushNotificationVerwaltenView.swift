//
//  PushNotificationVerwaltenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import FirebaseMessaging
import SwiftData

struct PushNotificationVerwaltenView: View {
    
    @StateObject var viewModel: PushNotificationVerwaltenViewModel
    @Query private var topicsQuery: [SubscribedFCMNotificationTopicDao]
    var topicsState: UiState<[SeesturmFCMNotificationTopic]> {
        do {
            let topics = try topicsQuery.map { try $0.getTopic() }
            return .success(data: topics)
        }
        catch {
            return .error(message: "Abonnierte Push-Nachrichten konnten nicht ermittelt werden. Installiere die App neu, um den Fehler zu beheben.")
        }
    }
    
    let sections: [FormSection: [Int: SeesturmFCMNotificationTopic]] = [
        FormSection(
            header: "Aktuell",
            footer: "Erhalte eine Benachrichtigung wenn ein neuer Post veröffentlicht wird",
            order: 1
        ): [1: .aktuell],
        FormSection(
            header: "Nächste Aktivität",
            footer: "Erhalte eine Benachrichtigung wenn die Infos zur nächsten Aktivität veröffentlicht werden",
            order: 2
        ): [1: .biberAktivitäten,
            2: .wolfAktivitäten,
            3: .pfadiAktivitäten,
            4: .pioAktivitäten]
    ]
    
    var body: some View {
        
        Form {
            switch topicsState {
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
                                state: viewModel.state.actionState,
                                isOn: data.contains(topic),
                                onToggle: { newValue in
                                    await viewModel.toggleTopic(topic: topic, isSwitchingOn: newValue)
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
        }
        .formStyle(.automatic)
        .navigationTitle("Push-Nachrichten")
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            "Push-Nachrichten nicht aktiviert",
            isPresented: viewModel.settingsAlertBinding,
            actions: {
                Button("Einstellungen") {
                    FCMManager.shared.goToNotificationSettings()
                }
                Button("OK", role: .cancel) {}
            },
            message: {
                Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        )
        .actionSnackbar(
            action: viewModel.actionStateBinding,
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

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext: ModelContext
    PushNotificationVerwaltenView(
        viewModel: PushNotificationVerwaltenViewModel(
            service: FCMSubscriptionService(
                repository: FCMRepositoryImpl(
                    api: FCMApiImpl(
                        messaging: Messaging.messaging()
                    )
                ),
                notificationCenter: UNUserNotificationCenter.current()
            ),
            modelContext: modelContext
        )
    )
}
