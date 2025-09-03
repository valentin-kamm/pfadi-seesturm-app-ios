//
//  Leiterbereich.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import SwiftUI
import FirebaseFunctions
import SwiftData

struct LeiterbereichView: View {
    
    @EnvironmentObject private var authState: AuthViewModel
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.accountModule) private var accountModule: AccountModule
    @Query private var stufenQuery: [SelectedStufeDao]
    @Query private var topicsQuery: [SubscribedFCMNotificationTopicDao]
    
    @State private var viewModel: LeiterbereichViewModel
    private let user: FirebaseHitobitoUser
    private let calendar: SeesturmCalendar
    
    init(
        viewModel: LeiterbereichViewModel,
        user: FirebaseHitobitoUser,
        calendar: SeesturmCalendar
    ) {
        self.viewModel = viewModel
        self.user = user
        self.calendar = calendar
    }
    
    private var selectedStufen: [SeesturmStufe] {
        do {
            return try stufenQuery.map { try $0.getStufe() }
        }
        catch {
            return []
        }
    }
    private var isPushNotificationsToggleOn: Bool {
        do {
            let topics = try topicsQuery.map { try $0.getTopic() }
            return topics.contains(.schoepflialarmReaction)
        }
        catch {
            return false
        }
    }
    
    var body: some View {
        
        LeiterbereichContentView(
            ordersState: viewModel.ordersState,
            schoepflialarmState: viewModel.schoepflialarmResult,
            termineState: viewModel.termineState,
            user: user,
            calendar: calendar,
            selectedStufen: selectedStufen,
            isPushNotificationsToggleOn: isPushNotificationsToggleOn,
            isEditAccountButtonLoading: authState.authState.signOutButtonIsLoading,
            onSignOut: {
                withAnimation {
                    viewModel.showSignOutConfirmationDialog = true
                }
            },
            onDeleteAccount: {
                withAnimation {
                    viewModel.showDeleteAccountConfirmationDialog = true
                }
            },
            onShowSchoepflialarmSheet: {
                withAnimation {
                    viewModel.showSchoepflialarmSheet = true
                }
            },
            onNeueAktivitaetButtonClick: { stufe in
                appState.appendToNavigationPath(
                    tab: .account,
                    destination: AccountNavigationDestination.aktivitaetBearbeiten(
                        mode: .insert,
                        stufe: stufe
                    )
                )
            },
            onNavigateToTermine: {
                appState.appendToNavigationPath(tab: .account, destination: AccountNavigationDestination.anlaesse)
            },
            onAddStufe: { stufe in
                withAnimation {
                    modelContext.insert(
                        SelectedStufeDao(stufe: stufe)
                    )
                    try? modelContext.save()
                }
            },
            onRemoveStufe: { stufe in
                let indices: [Int] = stufenQuery.enumerated().compactMap { index, dao in
                    (try? dao.getStufe()) == stufe ? index : nil
                }
                for index in indices {
                    withAnimation {
                        modelContext.delete(stufenQuery[index])
                        try? modelContext.save()
                    }
                }
            },
            onRetryTermine: viewModel.fetchNext3Events,
            showEditAccountSheet: $viewModel.showEditAccountSheet
        )
        .confirmationDialog(
            "Möchtest du dich wirklich abmelden?",
            isPresented: $viewModel.showSignOutConfirmationDialog,
            titleVisibility: .visible,
            actions: {
                Button("Abbrechen", role: .cancel) {
                    // do nothing
                }
                Button("Abmelden", role: .destructive) {
                    Task {
                        await authState.signOut(user: user)
                    }
                }
            }
        )
        .confirmationDialog(
            "Möchtest du deinen Account wirklich löschen?",
            isPresented: $viewModel.showDeleteAccountConfirmationDialog,
            titleVisibility: .visible,
            actions: {
                Button("Abbrechen", role: .cancel) {
                    // do nothing
                }
                Button("Löschen", role: .destructive) {
                    Task {
                        await authState.deleteAccount(user: user)
                    }
                }
            }
        )
        .alert(
            "Push-Nachrichten nicht aktiviert",
            isPresented: $viewModel.showNotificationSettingsAlert,
            actions: {
                Button("Einstellungen") {
                    viewModel.goToAppSettings()
                }
                Button("OK", role: .cancel) {
                    // do nothing
                }
            },
            message: {
                Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
            }
        )
        .alert(
            "Ortungsdienste nicht aktiviert",
            isPresented: $viewModel.showLocationSettingsAlert,
            actions: {
                Button("Einstellungen") {
                    viewModel.goToAppSettings()
                }
                Button("OK", role: .cancel) {
                    // do nothing
                }
            },
            message: {
                Text("Um diese Funktion nutzen zu können, musst du die Ortungsdienste in den Einstellungen aktivieren.")
            }
        )
        .customSnackbar(
            show: authState.signOutErrorSnackbarBinding(user: user),
            type: .error,
            message: authState.signOutErrorSnackbarMessage,
            dismissAutomatically: false,
            allowManualDismiss: true
        )
        .task {
            await viewModel.requestNotificationPermissionIfNecessary()
            await viewModel.loadData()
        }
        .sheet(isPresented: $viewModel.showSchoepflialarmSheet) {
            
            SchoepflialarmSheet(
                schoepflialarmResult: viewModel.schoepflialarmResult,
                user: user,
                newSchoepflialarmMessage: $viewModel.schoepflialarmMessage,
                onSubmit: viewModel.trySendSchoepflialarm,
                onConfirm: viewModel.sendSchoepflialarm,
                onReaction: viewModel.sendSchoepflialarmReaction,
                isReactionButtonLoading: { reaction in
                    switch viewModel.sendSchoepflialarmReactionState {
                    case .loading(let action):
                        return action == reaction
                    default:
                        return false
                    }
                },
                onPushNotificationToggle: { isSwitchingOn in
                    Task {
                        await viewModel.toggleSchoepflialarmReactionTopic(isSwitchingOn: isSwitchingOn)
                    }
                },
                isPushNotificationToggleOn: isPushNotificationsToggleOn,
                pushNotificationToggleState: viewModel.toggleSchoepflialarmReactionsPushNotificationState,
                confirmationDialogText: viewModel.schoepflialarmConfirmationText,
                isConfirmationDialogPresented: $viewModel.showConfirmSchoepflialarmAlert,
                sendSchoepflialarmState: $viewModel.sendSchoepflialarmState,
                sendSchoepflialarmReactionState: $viewModel.sendSchoepflialarmReactionState,
                togglePushNotificationState: $viewModel.toggleSchoepflialarmReactionsPushNotificationState
            )
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $viewModel.showEditAccountSheet) {
            EditProfileView(
                viewModel: EditProfileViewModel(
                    user: user,
                    leiterbereichService: accountModule.leiterbereichService
                ),
                leiterbereichViewModel: viewModel,
                user: user
            )
        }
    }
}

private struct LeiterbereichContentView: View {
    
    private let ordersState: UiState<[FoodOrder]>
    private let schoepflialarmState: UiState<Schoepflialarm>
    private let termineState: UiState<[GoogleCalendarEvent]>
    private let user: FirebaseHitobitoUser
    private let calendar: SeesturmCalendar
    private let selectedStufen: [SeesturmStufe]
    private let isPushNotificationsToggleOn: Bool
    private let isEditAccountButtonLoading: Bool
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    private let onShowSchoepflialarmSheet: () -> Void
    private let onNeueAktivitaetButtonClick: (SeesturmStufe) -> Void
    private let onNavigateToTermine: () -> Void
    private let onAddStufe: (SeesturmStufe) -> Void
    private let onRemoveStufe: (SeesturmStufe) -> Void
    private let onRetryTermine: () async -> Void
    private let showEditAccountSheet: Binding<Bool>
    
    init(
        ordersState: UiState<[FoodOrder]>,
        schoepflialarmState: UiState<Schoepflialarm>,
        termineState: UiState<[GoogleCalendarEvent]>,
        user: FirebaseHitobitoUser,
        calendar: SeesturmCalendar,
        selectedStufen: [SeesturmStufe],
        isPushNotificationsToggleOn: Bool,
        isEditAccountButtonLoading: Bool,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void,
        onShowSchoepflialarmSheet: @escaping () -> Void,
        onNeueAktivitaetButtonClick: @escaping (SeesturmStufe) -> Void,
        onNavigateToTermine: @escaping () -> Void,
        onAddStufe: @escaping (SeesturmStufe) -> Void,
        onRemoveStufe: @escaping (SeesturmStufe) -> Void,
        onRetryTermine: @escaping () async -> Void,
        showEditAccountSheet: Binding<Bool>
    ) {
        self.ordersState = ordersState
        self.schoepflialarmState = schoepflialarmState
        self.termineState = termineState
        self.user = user
        self.calendar = calendar
        self.selectedStufen = selectedStufen
        self.isPushNotificationsToggleOn = isPushNotificationsToggleOn
        self.isEditAccountButtonLoading = isEditAccountButtonLoading
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onShowSchoepflialarmSheet = onShowSchoepflialarmSheet
        self.onNeueAktivitaetButtonClick = onNeueAktivitaetButtonClick
        self.onNavigateToTermine = onNavigateToTermine
        self.onAddStufe = onAddStufe
        self.onRemoveStufe = onRemoveStufe
        self.onRetryTermine = onRetryTermine
        self.showEditAccountSheet = showEditAccountSheet
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            List {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        CircleProfilePictureView(
                            type: isEditAccountButtonLoading ? .loading : .user(user: user),
                            size: 60,
                            showEditBadge: true
                        )
                        .padding(.bottom, 4)
                        .onTapGesture {
                            showEditAccountSheet.wrappedValue = true
                        }
                        Text("Willkommen, \(user.displayNameShort)!")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .font(.callout)
                            .lineLimit(2)
                        if let em = user.email {
                            Text(em)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
                Section {
                    LeiterbereichTopHorizontalScrollView(
                        foodState: ordersState,
                        foodNavigationDestination: AccountNavigationDestination.food(user: user)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.top)
                    .padding(.bottom, -16)
                }
                Section {
                    switch schoepflialarmState {
                    case .loading(_):
                        SchoepflialarmLoadingCardView()
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding()
                    case .error(let message):
                        ErrorCardView(
                            errorDescription: message
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top)
                    case .success(let schoepflialarm):
                        SchoepflialarmCardView(
                            schoepflialarm: schoepflialarm,
                            user: user,
                            onClick: onShowSchoepflialarmSheet
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding()
                    }
                } header: {
                    MainSectionHeader(
                        headerType: .blank,
                        sectionTitle: "Schöpflialarm",
                        iconName: "iphone.homebutton.radiowaves.left.and.right.circle.fill"
                    )
                }
                Section {
                    LeiterbereichStufenScrollView(
                        stufen: selectedStufen,
                        screenWidth: geometry.size.width,
                        onNeueAktivitaetButtonClick: onNeueAktivitaetButtonClick
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                } header: {
                    MainSectionHeader(
                        headerType: .stufenButton(
                            selectedStufen: selectedStufen,
                            onClick: { stufe in
                                if selectedStufen.contains(stufe) {
                                    onRemoveStufe(stufe)
                                }
                                else {
                                    onAddStufe(stufe)
                                }
                            }
                        ),
                        sectionTitle: "Stufen",
                        iconName: "person.2.circle.fill"
                    )
                }
                Section {
                    switch termineState {
                    case .loading:
                        ForEach(0..<3) { index in
                            AnlassLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    case .error(let message):
                        ErrorCardView(
                            errorDescription: message,
                            action: .async(action: onRetryTermine)
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top)
                    case .success(let events):
                        if events.isEmpty {
                            Text("Keine bevorstehenden Termine")
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
                            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                AnlassCardView(
                                    event: event,
                                    calendar: calendar
                                )
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .background(
                                    NavigationLink(
                                        value: AccountNavigationDestination.anlassDetail(inputType: .object(object: event))) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                )
                            }
                        }
                    }
                } header: {
                    MainSectionHeader(
                        headerType: .button(
                            buttonTitle: "Alle",
                            icon: .system(name: "chevron.right"),
                            action: .sync(action: onNavigateToTermine)
                        ),
                        sectionTitle: "Termine",
                        iconName: "calendar.circle.fill"
                    )
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.customBackground)
            .navigationTitle("Schöpfli")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeiterbereichContentView(
            ordersState: .loading(subState: .loading),
            schoepflialarmState: .loading(subState: .loading),
            termineState: .loading(subState: .loading),
            user: DummyData.user1,
            calendar: .termineLeitungsteam,
            selectedStufen: [.biber, .wolf],
            isPushNotificationsToggleOn: false,
            isEditAccountButtonLoading: true,
            onSignOut: {},
            onDeleteAccount: {},
            onShowSchoepflialarmSheet: {},
            onNeueAktivitaetButtonClick: { _ in },
            onNavigateToTermine: {},
            onAddStufe: { _ in },
            onRemoveStufe: { _ in },
            onRetryTermine: {},
            showEditAccountSheet: .constant(false)
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeiterbereichContentView(
            ordersState: .error(message: "Schwerer Fehler"),
            schoepflialarmState: .error(message: "Schwerer Fehler"),
            termineState: .error(message: "Schwerer Fehler"),
            user: DummyData.user1,
            calendar: .termineLeitungsteam,
            selectedStufen: [.biber, .wolf],
            isPushNotificationsToggleOn: false,
            isEditAccountButtonLoading: false,
            onSignOut: {},
            onDeleteAccount: {},
            onShowSchoepflialarmSheet: {},
            onNeueAktivitaetButtonClick: { _ in },
            onNavigateToTermine: {},
            onAddStufe: { _ in },
            onRemoveStufe: { _ in },
            onRetryTermine: {},
            showEditAccountSheet: .constant(false)
        )
    }
}
#Preview("Erfolg (leere Termine)") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeiterbereichContentView(
            ordersState: .success(data: DummyData.foodOrders),
            schoepflialarmState: .success(data: DummyData.schoepflialarm),
            termineState: .success(data: []),
            user: DummyData.user1,
            calendar: .termineLeitungsteam,
            selectedStufen: [.biber, .wolf],
            isPushNotificationsToggleOn: false,
            isEditAccountButtonLoading: false,
            onSignOut: {},
            onDeleteAccount: {},
            onShowSchoepflialarmSheet: {},
            onNeueAktivitaetButtonClick: { _ in },
            onNavigateToTermine: {},
            onAddStufe: { _ in },
            onRemoveStufe: { _ in },
            onRetryTermine: {},
            showEditAccountSheet: .constant(false)
        )
    }
}
#Preview("Erfolg") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeiterbereichContentView(
            ordersState: .success(data: DummyData.foodOrders),
            schoepflialarmState: .success(data: DummyData.schoepflialarm),
            termineState: .success(data: [DummyData.allDayMultiDayEvent, DummyData.allDayOneDayEvent, DummyData.multiDayEvent]),
            user: DummyData.user1,
            calendar: .termineLeitungsteam,
            selectedStufen: [.biber, .wolf],
            isPushNotificationsToggleOn: false,
            isEditAccountButtonLoading: false,
            onSignOut: {},
            onDeleteAccount: {},
            onShowSchoepflialarmSheet: {},
            onNeueAktivitaetButtonClick: { _ in },
            onNavigateToTermine: {},
            onAddStufe: { _ in },
            onRemoveStufe: { _ in },
            onRetryTermine: {},
            showEditAccountSheet: .constant(false)
        )
    }
}
