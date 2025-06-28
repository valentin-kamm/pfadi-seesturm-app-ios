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
    
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    @Environment(\.firestoreModule) private var firestoreModule: FirestoreModule
    @Environment(\.authModule) private var authModule: AuthModule
    
    @State private var viewModel: HomeViewModel
    private let calendar: SeesturmCalendar
    
    init(
        viewModel: HomeViewModel,
        calendar: SeesturmCalendar
    ) {
        self.viewModel = viewModel
        self.calendar = calendar
    }
    
    var body: some View {
        NavigationStack(path: appState.path(for: .home)) {
            GeometryReader { geometry in
                HomeContentView(
                    aktuellState: viewModel.aktuellState,
                    anlaesseState: viewModel.anlaesseState,
                    naechsteAktivitaetState: viewModel.naechsteAktivitaetState,
                    weatherState: viewModel.weatherState,
                    width: geometry.size.width,
                    calendar: calendar,
                    selectedStufen: viewModel.selectedStufenState,
                    onAktivitaetRetry: { stufe in
                        Task {
                            await viewModel.fetchAktivitaet(for: stufe, isPullToRefresh: false)
                        }
                    },
                    onAktuellRetry: {
                        Task {
                            await viewModel.fetchLatestPost(isPullToRefresh: false)
                        }
                    },
                    onAnlaeseRetry: {
                        Task {
                            await viewModel.fetchNext3Events(isPullToRefresh: false)
                        }
                    },
                    onWeatherRetry: {
                        Task {
                            await viewModel.fetchForecast(isPullToRefresh: false)
                        }
                    },
                    onToggleStufe: viewModel.toggleStufe,
                    onChangeTab: appState.changeTab
                )
                .task {
                    await viewModel.loadInitialData()
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .actionSnackbar(
                    action: $viewModel.addRemoveStufenState,
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
                    calendar: calendar
                )
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

private struct HomeContentView: View {
    
    private let aktuellState: UiState<WordpressPost>
    private let anlaesseState: UiState<[GoogleCalendarEvent]>
    private let naechsteAktivitaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>]
    private let weatherState: UiState<Weather>
    private let width: CGFloat
    private let calendar: SeesturmCalendar
    private let selectedStufen: UiState<Set<SeesturmStufe>>
    private let onAktivitaetRetry: (SeesturmStufe) async -> Void
    private let onAktuellRetry: () async -> Void
    private let onAnlaeseRetry: () async -> Void
    private let onWeatherRetry: () async -> Void
    private let onToggleStufe: (SeesturmStufe) -> Void
    private let onChangeTab: (AppMainTab) -> Void
    
    init(
        aktuellState: UiState<WordpressPost>,
        anlaesseState: UiState<[GoogleCalendarEvent]>,
        naechsteAktivitaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>],
        weatherState: UiState<Weather>,
        width: CGFloat,
        calendar: SeesturmCalendar,
        selectedStufen: UiState<Set<SeesturmStufe>>,
        onAktivitaetRetry: @escaping (SeesturmStufe) async -> Void,
        onAktuellRetry: @escaping () async -> Void,
        onAnlaeseRetry: @escaping () async -> Void,
        onWeatherRetry: @escaping () async -> Void,
        onToggleStufe: @escaping (SeesturmStufe) -> Void,
        onChangeTab: @escaping (AppMainTab) -> Void
    ) {
        self.aktuellState = aktuellState
        self.anlaesseState = anlaesseState
        self.naechsteAktivitaetState = naechsteAktivitaetState
        self.weatherState = weatherState
        self.width = width
        self.calendar = calendar
        self.selectedStufen = selectedStufen
        self.onAktivitaetRetry = onAktivitaetRetry
        self.onAktuellRetry = onAktuellRetry
        self.onAnlaeseRetry = onAnlaeseRetry
        self.onWeatherRetry = onWeatherRetry
        self.onToggleStufe = onToggleStufe
        self.onChangeTab = onChangeTab
    }
    
    private var stufenForDropdown: [SeesturmStufe] {
        switch selectedStufen {
        case .success(let data):
            return Array(data)
        default:
            return []
        }
    }
    
    var body: some View {
        List {
            
            // nächste aktivität
            Section {
                switch selectedStufen {
                case .loading(_):
                    AktivitaetHomeLoadingView(
                        width: width - 32
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.horizontal)
                case .error(let message):
                    ErrorCardView(
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
                            .foregroundStyle(Color.secondary)
                    }
                    else {
                        AktivitaetHomeHorizontalScrollView(
                            stufen: stufen,
                            naechsteAktivtaetState: naechsteAktivitaetState,
                            screenWidth: width,
                            onRetry: onAktivitaetRetry
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            } header: {
                MainSectionHeader(
                    headerType: .stufenButton(
                        selectedStufen: stufenForDropdown,
                        onClick: onToggleStufe
                    ),
                    sectionTitle: "Nächste Aktivität",
                    iconName: "person.2.circle.fill"
                )
            }
            
            // Aktuell
            Section {
                switch aktuellState {
                case .loading(_):
                    AktuellLoadingCardView()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top)
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .async(action: onAktuellRetry)
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.top)
                case .success(let data):
                    AktuellCardView(
                        post: data,
                        width: width
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
                MainSectionHeader(
                    headerType: .button(
                        buttonTitle: "Mehr",
                        icon: .system(name: "chevron.right"),
                        action: .sync(action: {
                            onChangeTab(.aktuell)
                        })
                    ),
                    sectionTitle: "Aktuell",
                    iconName: "newspaper.circle.fill"
                )
            }
            
            // Anlässe
            Section {
                switch anlaesseState {
                case .loading(_):
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
                        action: .async(action: onAnlaeseRetry)
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
                            AnlassCardView(
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
                MainSectionHeader(
                    headerType: .button(
                        buttonTitle: "Mehr",
                        icon: .system(name: "chevron.right"),
                        action: .sync(action: {
                            onChangeTab(.anlässe)
                        })
                    ),
                    sectionTitle: "Anlässe",
                    iconName: "calendar.circle.fill"
                )
            }
            
            // Wetter
            Section {
                switch weatherState {
                case .loading(_):
                    WeatherLoadingView()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .async(action: onWeatherRetry)
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
                MainSectionHeader(
                    headerType: .blank,
                    sectionTitle: "Wetter",
                    iconName: "sun.max.circle.fill"
                )
            }
        }
        .background(Color.customBackground)
        .navigationTitle("Pfadi Seesturm")
        .navigationBarTitleDisplayMode(.large)
        .listStyle(PlainListStyle())
    }
}

#Preview("Loading1") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .loading(subState: .loading),
                anlaesseState: .loading(subState: .loading),
                naechsteAktivitaetState: [.biber: .loading(subState: .loading)],
                weatherState: .loading(subState: .loading),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .loading(subState: .loading),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("Loading2") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .loading(subState: .loading),
                anlaesseState: .loading(subState: .loading),
                naechsteAktivitaetState: [
                    .biber: .loading(subState: .loading),
                    .wolf: .loading(subState: .loading)
                ],
                weatherState: .loading(subState: .loading),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .success(data: [.biber, .wolf]),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("Error1") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .error(message: "Schwerer Fehler"),
                anlaesseState: .error(message: "Schwerer Fehler"),
                naechsteAktivitaetState: [:],
                weatherState: .error(message: "Schwerer Fehler"),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .error(message: "Schwerer Fehler"),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("Error2") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .error(message: "Schwerer Fehler"),
                anlaesseState: .error(message: "Schwerer Fehler"),
                naechsteAktivitaetState: [.biber: .error(message: "Schwerer Fehler")],
                weatherState: .error(message: "Schwerer Fehler"),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .success(data: [.biber]),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("Empty anlässe and no event") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .success(data: DummyData.aktuellPost1),
                anlaesseState: .success(data: []),
                naechsteAktivitaetState: [.biber: .success(data: nil)],
                weatherState: .success(data: DummyData.weather),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .success(data: [.biber]),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("No stufe selected") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .success(data: DummyData.aktuellPost1),
                anlaesseState: .success(data: []),
                naechsteAktivitaetState: [:],
                weatherState: .success(data: DummyData.weather),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .success(data: []),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
#Preview("Success") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            HomeContentView(
                aktuellState: .success(data: DummyData.aktuellPost1),
                anlaesseState: .success(data: [DummyData.oneDayEvent, DummyData.multiDayEvent, DummyData.allDayOneDayEvent]),
                naechsteAktivitaetState: [.biber: .success(data: DummyData.aktivitaet1)],
                weatherState: .success(data: DummyData.weather),
                width: geometry.size.width,
                calendar: .termine,
                selectedStufen: .success(data: [.biber]),
                onAktivitaetRetry: { _ in },
                onAktuellRetry: {},
                onAnlaeseRetry: {},
                onWeatherRetry: {},
                onToggleStufe: { _ in },
                onChangeTab: { _ in }
            )
        }
    }
}
