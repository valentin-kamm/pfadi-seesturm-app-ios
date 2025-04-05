//
//  Leiterbereich.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import SwiftUI
import FirebaseFunctions
import SwiftData

struct Leiterbereich: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    @StateObject var viewModel: LeiterbereichViewModel
    @Environment(\.modelContext) var modelContext: ModelContext
    @Query private var stufenQuery: [SelectedStufeDao]
    let user: FirebaseHitobitoUser
    let calendar: SeesturmCalendar
    
    private var selectedStufen: [SeesturmStufe] {
        do {
            return try stufenQuery.map { try $0.getStufe() }
        }
        catch {
            return []
        }
    }
    var stufenDropdownText: String {
        if selectedStufen.count == 0 {
            "Wählen"
        }
        else if selectedStufen.count == 1 {
            selectedStufen.first?.stufenName ?? "Wählen"
        }
        else if selectedStufen.count == 4 {
            "Alle"
        }
        else {
            "Mehrere"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section {
                    LeiterbereichProfileHeaderView(
                        user: user,
                        isLoading: appState.deleteAccountButtonLoading,
                        onSignOut: {
                            viewModel.changeSignOutConfirmationDialogVisibility(isVisible: true)
                        },
                        onDeleteAccount: {
                            viewModel.changeDeleteAccountConfirmationDialogVisibility(isVisible: true)
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
                }
                Section {
                    LeiterbereichTopHorizontalScrollView(
                        foodState: viewModel.ordersState,
                        foodNavigationDestination: AccountNavigationDestination.food(user: user))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top)
                        .padding(.bottom, -16)
                }
                Section {
                    /*
                     SchöpflialarmCardView(viewModel: viewModel)
                         .listRowSeparator(.hidden)
                         .listRowInsets(EdgeInsets())
                         .listRowBackground(Color.clear)
                         .padding()
                     */
                } header: {
                    ListSectionHeaderWithButton(
                        headerType: .blank,
                        sectionTitle: "Schöpflialarm",
                        iconName: "iphone.homebutton.radiowaves.left.and.right.circle.fill"
                    )
                }
                Section {
                    LeiterbereichStufenScrollView(
                        selectedStufen: selectedStufen,
                        screenWidth: geometry.size.width,
                        onNeueAktivitaetButtonClick: { stufe in
                            appState.appendToNavigationPath(
                                tab: .account,
                                destination: AccountNavigationDestination.stufenbereich(stufe: stufe, initialSheetMode: .insert)
                            )
                        }
                    )
                } header: {
                    HStack(alignment: .center) {
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundStyle(Color.SEESTURM_RED)
                        Spacer(minLength: 16)
                        Text("Stufen")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .fontWeight(.bold)
                        DropdownButton(
                            items: SeesturmStufe.allCases.map {
                                DropdownItemImpl(
                                    title: $0.stufenName,
                                    item: $0,
                                    icon: .checkmark(isShown: selectedStufen.contains($0))
                                )
                            },
                            onItemClick: { item in
                                if selectedStufen.contains(item.item) {
                                    let indices: [Int] = stufenQuery.enumerated().compactMap { index, dao in
                                        (try? dao.getStufe()) == item.item ? index : nil
                                    }
                                    for index in indices {
                                        withAnimation {
                                            modelContext.delete(stufenQuery[index])
                                            try? modelContext.save()
                                        }
                                    }
                                }
                                else {
                                    withAnimation {
                                        modelContext.insert(
                                            SelectedStufeDao(stufe: item.item)
                                        )
                                        try? modelContext.save()
                                    }
                                }
                            },
                            title: stufenDropdownText
                        )
                    }
                    .padding(.vertical, 8)
                    
                }
                Section {
                    switch viewModel.state.termineState {
                    case .loading:
                        ForEach(0..<3) { index in
                            TermineLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    case .error(let message):
                        CardErrorView(
                            errorDescription: message,
                            asyncRetryAction: {
                                await viewModel.fetchNext3Events()
                            }
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
                                TermineCardView(
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
                    ListSectionHeaderWithButton(
                        headerType: .button(
                            buttonTitle: "Alle",
                            icon: .system(name: "chevron.right"),
                            action: .sync(action: {
                                appState.appendToNavigationPath(
                                    tab: .account,
                                    destination: AccountNavigationDestination.anlaesse
                                )
                            })
                        ),
                        sectionTitle: "Termine",
                        iconName: "calendar.circle.fill"
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.customBackground)
        .navigationTitle("Schöpfli")
        .navigationBarTitleDisplayMode(.large)
        .confirmationDialog(
            "Möchtest du dich wirklich abmelden?",
            isPresented: viewModel.signOutConfirmationDialogBinding,
            titleVisibility: .visible,
            actions: {
                Button("Abbrechen", role: .cancel) {
                    // do nothing
                }
                Button("Abmelden", role: .destructive) {
                    appState.signOut(user: user, viewModel: viewModel)
                }
            }
        )
        .confirmationDialog(
            "Möchtest du deinen Account wirklich löschen?",
            isPresented: viewModel.deleteAccountConfirmationDialogBinding,
            titleVisibility: .visible,
            actions: {
                Button("Abbrechen", role: .cancel) {
                    // do nothing
                }
                Button("Löschen", role: .destructive) {
                    Task {
                        await appState.deleteAccount(user: user, viewModel: viewModel)
                    }
                }
            }
        )
        .customSnackbar(
            show: appState.authErrorSnackbarBinding(user: user, viewModel: viewModel),
            type: .error,
            message: appState.authErrorSnackbarMessage,
            dismissAutomatically: false,
            allowManualDismiss: true
        )
        .task {
            await viewModel.loadData()
        }
    }
}
    
#Preview {
    let user = FirebaseHitobitoUser(
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
    Leiterbereich(
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
            userId: "123"
        ),
        user: user,
        calendar: .termineLeitungsteam
    )
    .environmentObject(
        AppStateViewModel(
            authService: AuthService(
                authRepository: AuthRepositoryImpl(
                    authApi: AuthApiImpl(
                        appConfig: Constants.OAUTH_CONFIG,
                        firebaseAuth: .auth()
                    )
                ),
                cloudFunctionsRepository: CloudFunctionsRepositoryImpl(
                    api: CloudFunctionsApiImpl(
                        functions: .functions()
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: .firestore(),
                    api: FirestoreApiImpl(db: .firestore())
                )
            ),
            leiterbereichService: LeiterbereichService(
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
            universalLinksHandler: UniversalLinksHandler()
        )
    )
}
             
/*
             List {
                 Section {
                     LeiterbereichProfileHeader(user: user)
                 }
                 
                 }
                 
                 
                 Section(header:
                 ) {
                     switch viewModel.termineLoadingState {
                     case .loading, .none, .errorWithReload(_):
                         ForEach(0..<3) { index in
                             TermineLoadingCardView()
                                 .padding(.top, index == 0 ? 16 : 0)
                                 .listRowSeparator(.hidden)
                                 .listRowInsets(EdgeInsets())
                                 .listRowBackground(Color.clear)
                         }
                     case .result(.failure(let error)):
                         CardErrorView(
                             errorTitle: "Ein Fehler ist aufgetreten",
                             errorDescription: error.localizedDescription,
                             asyncRetryAction: {
                                 await viewModel.fetchNext3LeiterbereichEvents(isPullToRefresh: false)
                             }
                         )
                         .listRowSeparator(.hidden)
                         .listRowInsets(EdgeInsets())
                         .listRowBackground(Color.clear)
                         .padding(.top)
                     case .result(.success(let events)):
                         if events.isEmpty {
                             Text("Keine bevorstehenden Anlässe")
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
                                 TermineCardView(event: event, isLeitungsteam: true)
                                     .padding(.top, index == 0 ? 16 : 0)
                                     .listRowSeparator(.hidden)
                                     .listRowInsets(EdgeInsets())
                                     .listRowBackground(Color.clear)
                                     .background(
                                         NavigationLink(value: event, label: {
                                             EmptyView()
                                         })
                                         .opacity(0)
                                     )
                             }
                         }
                     }
                 }
                 
             }
             
              */
         /*
         
         .task {
             do {
                 try await FCMManager.shared.requestOrCheckNotificationPermission()
             }
             catch {
                 print("Notification permission not granted")
             }
         }
         .task {
             if viewModel.termineLoadingState.taskShouldRun {
                 await viewModel.fetchNext3LeiterbereichEvents(isPullToRefresh: false)
             }
         }
         .alert("Push-Nachrichten nicht aktiviert", isPresented: $viewModel.showNotificationsSettingsAlert) {
             Button("Einstellungen") {
                 FCMManager.shared.goToNotificationSettings()
             }
             Button("OK", role: .cancel) {}
         } message: {
             Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
         }
         .alert("Ortungsdienste nicht aktiviert", isPresented: $viewModel.showLocationSettingsAlert) {
             Button("Einstellungen") {
                 FCMManager.shared.goToNotificationSettings()
             }
             Button("OK", role: .cancel) {}
         } message: {
             Text("Um diese Funktion nutzen zu können, musst du die Ortungsdienste in den Einstellungen aktivieren.")
         }
         .alert("Genauer Standort nicht aktiviert", isPresented: $viewModel.showLocationAccuracySettingsAlert) {
             Button("Einstellungen") {
                 FCMManager.shared.goToNotificationSettings()
             }
             Button("OK", role: .cancel) {}
         } message: {
             Text("Um diese Funktion nutzen zu können, wird dein genauer Standort benötigt.")
         }
         .confirmationDialog("Möchtest du den Schöpflialarm wirklich senden?", isPresented: $viewModel.showWirklichSendenAlert, titleVisibility: .visible, actions: {
             Button("Abbrechen", role: .cancel) {
                 viewModel.wirklichSendenContinuation?.resume(throwing: PfadiSeesturmAppError.cancellationError(message: "Operation wurde durch den Benutzer abgebrochen."))
             }
             Button("Senden") {
                 viewModel.wirklichSendenContinuation?.resume()
             }
         }, message: {
             Text("Der Schöpflialarm wird ohne Nachricht gesendet.")
         })
         .snackbar(
             loadingState: $viewModel.sendSchöpflialarmLoadingState,
             dismissAutomatically: false,
             allowManualDismiss: true
         )
          */
