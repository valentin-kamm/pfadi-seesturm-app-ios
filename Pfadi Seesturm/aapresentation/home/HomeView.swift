//
//  HomeView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import SwiftData
import FirebaseFirestore
import FirebaseFunctions

struct HomeView: View {
    
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @StateObject var viewModel: HomeViewModel
    
    let calendar: SeesturmCalendar
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    @Environment(\.firestoreModule) private var firestoreModule: FirestoreModule
    @Environment(\.authModule) private var authModule: AuthModule
            
    var body: some View {
        NavigationStack(path: appState.homeNavigationPathBinding) {
            GeometryReader { geometry in
                List {
                    // nächste aktivität
                    Section {
                        switch viewModel.state.selectedStufen {
                        case .loading(_):
                            EmptyView()
                        case .error(let message):
                            CardErrorView(
                                errorDescription: message
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success(let stufen):
                            if stufen.isEmpty {
                                Text("Wähle eine Stufe aus, um die Infos zur nächsten Aktivität anzuzeigen")
                                    .padding(.horizontal)
                                    .padding(.vertical, 75)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .multilineTextAlignment(.center)
                            }
                            else {
                                AktivitaetHomeHorizontalScrollView(
                                    stufen: stufen,
                                    naechsteAktivtaetState: viewModel.state.naechsteAktivitaetState,
                                    screenWidth: geometry.size.width
                                ) { stufe in
                                    await viewModel.fetchAktivitaet(stufe: stufe, isPullToRefresh: false)
                                }
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                            }
                        }
                    } header: {
                        HStack(alignment: .center) {
                            Image(systemName: "person.2.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundStyle(Color.SEESTURM_RED)
                            Spacer(minLength: 16)
                            Text("Nächste Aktivität")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer(minLength: 16)
                            DropdownButton(
                                items: SeesturmStufe.allCases.map {
                                    DropdownItemImpl(
                                        title: $0.stufenName,
                                        item: $0,
                                        icon: .checkmark(isShown: viewModel.isStufeSelected(stufe: $0))
                                    )
                                },
                                onItemClick: { item in
                                    viewModel.toggleStufe(stufe: item.item)
                                },
                                title: viewModel.stufenDropdownText,
                                isDisabled: !viewModel.state.selectedStufen.isSuccess
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Aktuell
                    Section {
                        switch viewModel.state.aktuellState {
                        case .loading(_):
                            AktuellSkeletonCardView()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.top)
                        case .error(let message):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: message,
                                asyncRetryAction: {
                                    await viewModel.fetchLatestPost(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success(let data):
                            AktuellCardView(
                                post: data,
                                width: geometry.size.width
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                            .background(
                                NavigationLink(value: HomeNavigationDestination.aktuellDetail(inputType: .object(object: data))) {
                                    EmptyView()
                                }
                                    .opacity(0)
                            )
                        }
                    } header: {
                        ListSectionHeaderWithButton(
                            headerType: .button(
                                buttonTitle: "Mehr",
                                icon: .system(name: "chevron.right"),
                                action: .sync(action: {
                                    appState.changeTab(newTab: .aktuell)
                                })
                            ),
                            sectionTitle: "Aktuell",
                            iconName: "newspaper.circle.fill"
                        )
                    }
                    
                    // Anlässe
                    Section {
                        switch viewModel.state.anlaesseState {
                        case .loading(_):
                            ForEach(0..<3) { index in
                                TermineLoadingCardView()
                                    .padding(.top, index == 0 ? 16 : 0)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        case .error(let message):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: message,
                                asyncRetryAction: {
                                    await viewModel.fetchNext3Events(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success(let events):
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
                                    TermineCardView(
                                        event: event,
                                        calendar: calendar
                                    )
                                    .padding(.top, index == 0 ? 16 : 0)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .background(
                                        NavigationLink(value: HomeNavigationDestination.anlassDetail(inputType: .object(object: event))) {
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
                                buttonTitle: "Mehr",
                                icon: .system(name: "chevron.right"),
                                action: .sync(action: {
                                    appState.changeTab(newTab: .anlässe)
                                })
                            ),
                            sectionTitle: "Anlässe",
                            iconName: "calendar.circle.fill"
                        )
                    }
                    
                    // Wetter
                    Section {
                        switch viewModel.state.weatherState {
                        case .loading(_):
                            WeatherLoadingView()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        case .error(let message):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: message,
                                asyncRetryAction: {
                                    await viewModel.fetchForecast(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.vertical)
                        case .success(let weather):
                            WeatherCardView(weather: weather)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    } header: {
                        ListSectionHeaderWithButton(
                            headerType: .blank,
                            sectionTitle: "Wetter",
                            iconName: "sun.max.circle.fill"
                        )
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.customBackground)
                .task {
                    await viewModel.loadInitialData()
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .navigationTitle("Pfadi Seesturm")
                .navigationBarTitleDisplayMode(.large)
                .actionSnackbar(
                    action: viewModel.addRemoveStufenStateBinding,
                    events: [
                        .error(
                            dismissAutomatically: true,
                            allowManualDismiss: true
                        )
                    ],
                    defaultErrorMessage: "Eine Stufe konnte nicht entfernt/hinzugefügt werden. Unbekannter Fehler."
                )
                .homeNavigationDestinations(
                    wordpressModule: wordpressModule,
                    fcmModule: fcmModule,
                    authModule: authModule,
                    calendar: calendar,
                    modelContext: modelContext
                )
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview {
    @Previewable @Environment(\.modelContext) var modelContext: ModelContext
    HomeView(
        viewModel: HomeViewModel(
            modelContext: modelContext,
            calendar: .termine,
            naechsteAktivitaetService: NaechsteAktivitaetService(
                repository: NaechsteAktivitaetRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: Firestore.firestore(),
                    api: FirestoreApiImpl(
                        db: Firestore.firestore()
                    )
                )
            ),
            aktuellService: AktuellService(
                repository: AktuellRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            anlaesseService: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            weatherService: WeatherService(
                repository: WeatherRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        ),
        calendar: .termine
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
                        functions: Functions.functions()
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: .firestore(),
                    api: FirestoreApiImpl(
                        db: .firestore()
                    )
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
