//
//  SchoepflialarmSheet.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.04.2025.
//

import SwiftUI

struct SchoepflialarmSheet: View {
    
    @State private var showConfirmationDialog: Bool = false
    
    private let schoepflialarmResult: UiState<Schoepflialarm>
    private let user: FirebaseHitobitoUser
    private let newSchoepflialarmMessage: Binding<String>
    private let onSendSchoepflialarm: (SchoepflialarmMessageType) async -> Void
    private let onReaction: (SchoepflialarmReactionType) async -> Void
    private let isReactionButtonLoading: (SchoepflialarmReactionType) -> Bool
    private let onPushNotificationToggle: (Bool) -> Void
    private let isPushNotificationToggleOn: Bool
    private let pushNotificationToggleState: ActionState<SeesturmFCMNotificationTopic>
    private let sendSchoepflialarmState: Binding<ActionState<Void>>
    private let sendSchoepflialarmReactionState: Binding<ActionState<SchoepflialarmReactionType>>
    private let togglePushNotificationState: Binding<ActionState<SeesturmFCMNotificationTopic>>
        
    init(
        schoepflialarmResult: UiState<Schoepflialarm>,
        user: FirebaseHitobitoUser,
        newSchoepflialarmMessage: Binding<String>,
        onSendSchoepflialarm: @escaping (SchoepflialarmMessageType) async -> Void,
        onReaction: @escaping (SchoepflialarmReactionType) async -> Void,
        isReactionButtonLoading: @escaping (SchoepflialarmReactionType) -> Bool,
        onPushNotificationToggle: @escaping (Bool) -> Void,
        isPushNotificationToggleOn: Bool,
        pushNotificationToggleState: ActionState<SeesturmFCMNotificationTopic>,
        sendSchoepflialarmState: Binding<ActionState<Void>>,
        sendSchoepflialarmReactionState: Binding<ActionState<SchoepflialarmReactionType>>,
        togglePushNotificationState: Binding<ActionState<SeesturmFCMNotificationTopic>>
    ) {
        self.schoepflialarmResult = schoepflialarmResult
        self.user = user
        self.newSchoepflialarmMessage = newSchoepflialarmMessage
        self.onSendSchoepflialarm = onSendSchoepflialarm
        self.onReaction = onReaction
        self.isReactionButtonLoading = isReactionButtonLoading
        self.onPushNotificationToggle = onPushNotificationToggle
        self.isPushNotificationToggleOn = isPushNotificationToggleOn
        self.pushNotificationToggleState = pushNotificationToggleState
        self.sendSchoepflialarmState = sendSchoepflialarmState
        self.sendSchoepflialarmReactionState = sendSchoepflialarmReactionState
        self.togglePushNotificationState = togglePushNotificationState
    }
    
    private var schoepflialarmMessageType: SchoepflialarmMessageType {
        let message = newSchoepflialarmMessage.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            return .generic
        }
        return .custom(message: message)
    }
    private var confirmationDialogText: String {
        switch schoepflialarmMessageType {
        case .generic:
            return "Der Schöpflialarm wird ohne Nachricht gesendet."
        case .custom(_):
            return "Möchtest du den Schöpflialarm wirklich senden?"
        }
    }
    
    private var isReactionButtonDisabled: Bool {
        if case .success(let data) = schoepflialarmResult {
            return isReactionButtonLoading(.coming) ||
                isReactionButtonLoading(.notComing) ||
                isReactionButtonLoading(.alreadyThere) ||
                data.reactions.map { $0.user?.userId ?? "" }.contains(user.userId)
        }
        else {
            return true
        }
    }
    
    private var isSendingSchoepflialarmDisabled: Bool {
        if case .success(_) = schoepflialarmResult {
            return sendSchoepflialarmState.wrappedValue.isLoading
        }
        else {
            return true
        }
    }
    
    private enum SchoepflialarmFields: String, FocusControlItem {
        case message
        var id: SchoepflialarmFields { self }
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            FocusControlView(allFields: SchoepflialarmFields.allCases) { focused in
                ZStack(alignment: .bottom) {
                    List {
                        switch schoepflialarmResult {
                        case .loading(_):
                            Section {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .center, spacing: 16) {
                                        Circle()
                                            .fill(Color.skeletonPlaceholderColor)
                                            .frame(width: 30, height: 30)
                                            .loadingBlinking()
                                        Text(Constants.PLACEHOLDER_TEXT)
                                            .font(.callout)
                                            .lineLimit(1)
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.bold)
                                            .layoutPriority(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .redacted(reason: .placeholder)
                                            .loadingBlinking()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text(Constants.PLACEHOLDER_TEXT)
                                        .font(.callout)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .redacted(reason: .placeholder)
                                        .loadingBlinking()
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            ForEach(SchoepflialarmReactionType.allCases.sorted { $0.sortingOrder < $1.sortingOrder }) { reactionType in
                                
                                Section {
                                    Text("Keine Reaktionen")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.leading)
                                        .layoutPriority(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .redacted(reason: .placeholder)
                                        .loadingBlinking()
                                } header: {
                                    Text(reactionType.title)
                                        .lineLimit(1)
                                        .redacted(reason: .placeholder)
                                        .loadingBlinking()
                                }
                            }
                        case .error(let message):
                            ErrorCardView(
                                errorDescription: message
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success(let schoepflialarm):
                            Section {
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .center, spacing: 16) {
                                        CircleProfilePictureView(
                                            type: .idle(user: schoepflialarm.user),
                                            size: 30
                                        )
                                        Text(schoepflialarm.user?.displayNameShort ?? "Unbekannter Benutzer")
                                            .font(.callout)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .fontWeight(.bold)
                                            .layoutPriority(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(schoepflialarm.createdFormatted)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.trailing)
                                            .foregroundStyle(Color.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    Text(schoepflialarm.message)
                                        .font(.callout)
                                        .multilineTextAlignment(.leading)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            ForEach(SchoepflialarmReactionType.allCases.sorted { $0.sortingOrder < $1.sortingOrder }) { reactionType in
                                
                                Section {
                                    
                                    let reactions = schoepflialarm.reactions(for: reactionType)
                                    
                                    if reactions.count > 0 {
                                        ForEach(reactions) { reaction in
                                            HStack(alignment: .center, spacing: 16) {
                                                CircleProfilePictureView(
                                                    type: .idle(user: reaction.user),
                                                    size: 20
                                                )
                                                Text(reaction.user?.displayNameShort ?? "Unbekannter Benutzer")
                                                    .font(.subheadline)
                                                    .multilineTextAlignment(.leading)
                                                    .layoutPriority(1)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                Text(reaction.createdFormatted)
                                                    .font(.caption)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.trailing)
                                                    .foregroundStyle(Color.secondary)
                                            }
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        }
                                    }
                                    else {
                                        Text("Keine Reaktionen")
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .layoutPriority(1)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                } header: {
                                    Label(title: {
                                        Text("\(reactionType.title) (\(schoepflialarm.reactionCount(for: reactionType)))")
                                            .lineLimit(1)
                                    }, icon: {
                                        Image(systemName: reactionType.systemImageName)
                                            .foregroundStyle(reactionType.color)
                                    })
                                }
                            }
                            
                            Section {
                                HStack(alignment: .center, spacing: 16) {
                                    ForEach(SchoepflialarmReactionType.allCases.sorted { $0.sortingOrder < $1.sortingOrder }) { reactionType in
                                        
                                        SeesturmButton(
                                            type: .secondary,
                                            action: .async(action: {
                                                await onReaction(reactionType)
                                            }),
                                            title: nil,
                                            icon: .system(name: reactionType.systemImageName),
                                            colors: .custom(
                                                contentColor: reactionType.onReactionColor,
                                                buttonColor: reactionType.color
                                            ),
                                            isLoading: isReactionButtonLoading(reactionType),
                                            disabled: isReactionButtonDisabled,
                                            maxWidth: .infinity
                                        )
                                        .padding(.vertical, 4)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                PushNotificationToggle(
                                    topic: .schoepflialarmReaction,
                                    state: pushNotificationToggleState,
                                    isOn: isPushNotificationToggleOn,
                                    onToggle: onPushNotificationToggle
                                )
                            } header: {
                                Text("Reagieren")
                            }
                        }
                    }
                    .dynamicListStyle(isListPlain: schoepflialarmResult.isError)
                    .safeAreaInset(edge: .bottom) {
                        Spacer()
                            .frame(height: 80)
                    }
                    
                    HStack(alignment: .center, spacing: 8) {
                        TextField("Sende einen Schöplialarm...", text: newSchoepflialarmMessage)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isSendingSchoepflialarmDisabled)
                            .focused(focused, equals: .message)
                            .submitLabel(.done)
                            .onSubmit {
                                focused.wrappedValue = nil
                            }
                        SeesturmButton(
                            type: .secondary,
                            action: .sync(action: { showConfirmationDialog = true }),
                            title: nil,
                            icon: .system(name: "arrow.up"),
                            isLoading: sendSchoepflialarmState.wrappedValue.isLoading,
                            disabled: isSendingSchoepflialarmDisabled
                        )
                        .confirmationDialog(
                            confirmationDialogText,
                            isPresented: $showConfirmationDialog,
                            titleVisibility: .visible,
                            actions: {
                                Button("Abbrechen", role: .cancel) { }
                                Button("Senden", role: .destructive) {
                                    Task {
                                        await onSendSchoepflialarm(schoepflialarmMessageType)
                                    }
                                }
                            }
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment.topLeading)
            .navigationTitle("Schöpflialarm")
            .navigationBarTitleDisplayMode(.inline)
            .actionSnackbar(
                action: sendSchoepflialarmState,
                events: [
                    .success(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    ),
                    .error(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    )
                ],
                defaultErrorMessage: "Beim Senden des Schöpflialarms ist ein unbekannter Fehler aufgetreten",
                defaultSuccessMessage: "Schöpflialarm erfolgreich gesendet"
            )
            .actionSnackbar(
                action: sendSchoepflialarmReactionState,
                events: [
                    .success(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    ),
                    .error(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    )
                ],
                defaultErrorMessage: "Beim Senden der Reaktion ist ein unbekannter Fehler aufgetreten",
                defaultSuccessMessage: "Reaktion erfolgreich gesendet"
            )
            .actionSnackbar(
                action: togglePushNotificationState,
                events: [
                    .success(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    ),
                    .error(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    )
                ],
                defaultErrorMessage: "Push-Nachrichten konnten nicht aktiviert/deaktiviert werden. Unbekannter Fehler",
                defaultSuccessMessage: "Push-Nachrichten erfolgreich aktiviert/deaktiviert"
            )
        }
    }
}

#Preview("Loading") {
    SchoepflialarmSheet(
        schoepflialarmResult: .loading(subState: .loading),
        user: DummyData.user1,
        newSchoepflialarmMessage: .constant("Hallo"),
        onSendSchoepflialarm: { _ in },
        onReaction: { _ in },
        isReactionButtonLoading: { _ in false },
        onPushNotificationToggle: { _ in },
        isPushNotificationToggleOn: true,
        pushNotificationToggleState: .idle,
        sendSchoepflialarmState: .constant(.idle),
        sendSchoepflialarmReactionState: .constant(.idle),
        togglePushNotificationState: .constant(.idle)
    )
}
#Preview("Error") {
    SchoepflialarmSheet(
        schoepflialarmResult: .error(message: "Schlimmer Fehler"),
        user: DummyData.user1,
        newSchoepflialarmMessage: .constant("Hallo"),
        onSendSchoepflialarm: { _ in },
        onReaction: { _ in },
        isReactionButtonLoading: { _ in false },
        onPushNotificationToggle: { _ in },
        isPushNotificationToggleOn: true,
        pushNotificationToggleState: .idle,
        sendSchoepflialarmState: .constant(.idle),
        sendSchoepflialarmReactionState: .constant(.idle),
        togglePushNotificationState: .constant(.idle)
    )
}
#Preview("Success") {
    SchoepflialarmSheet(
        schoepflialarmResult: .success(data: DummyData.schoepflialarm),
        user: DummyData.user1,
        newSchoepflialarmMessage: .constant("Hallo"),
        onSendSchoepflialarm: { _ in },
        onReaction: { _ in },
        isReactionButtonLoading: { _ in false },
        onPushNotificationToggle: { _ in },
        isPushNotificationToggleOn: false,
        pushNotificationToggleState: .idle,
        sendSchoepflialarmState: .constant(.loading(action: ())),
        sendSchoepflialarmReactionState: .constant(.idle),
        togglePushNotificationState: .constant(.idle)
    )
}
