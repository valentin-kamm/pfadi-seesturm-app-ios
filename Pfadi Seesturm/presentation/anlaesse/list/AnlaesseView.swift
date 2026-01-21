//
//  AnlaesseView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AnlaesseView: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    @EnvironmentObject private var authState: AuthViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.accountModule) private var accountModule: AccountModule
    
    @State private var viewModel: AnlaesseViewModel
    private let calendar: SeesturmCalendar
    
    init(
        viewModel: AnlaesseViewModel,
        calendar: SeesturmCalendar
    ) {
        self.viewModel = viewModel
        self.calendar = calendar
    }
    
    var body: some View {
        Group {
            if calendar.isLeitungsteam {
                AnlaesseIntermediateView(
                    viewModel: viewModel,
                    calendar: calendar,
                    canEditEvents: authState.authState.isAdminSignedIn,
                    navigationDestination: { event in
                        AccountNavigationDestination.anlassDetail(inputType: .object(object: event))
                    },
                    onManageEvent: { mode in
                        appState.appendToNavigationPath(
                            tab: .account,
                            destination: AccountNavigationDestination.manageEvent(type: .termin(calendar: calendar, mode: mode))
                        )
                    }
                )
            }
            else {
                NavigationStack(path: appState.path(for: .anlässe)) {
                    AnlaesseIntermediateView(
                        viewModel: viewModel,
                        calendar: calendar,
                        canEditEvents: authState.authState.isAdminSignedIn,
                        navigationDestination: { event in
                            AnlaesseNavigationDestination.detail(inputType: .object(object: event))
                        },
                        onManageEvent: { mode in
                            appState.appendToNavigationPath(
                                tab: .anlässe,
                                destination: AnlaesseNavigationDestination.manageTermin(calendar: calendar, mode: mode)
                            )
                        }
                    )
                    .anlaesseNavigationDestinations(
                        appState: appState,
                        wordpressModule: wordpressModule,
                        accountModule: accountModule,
                        calendar: calendar
                    )
                }
            }
        }
    }
}

private struct AnlaesseIntermediateView<N: NavigationDestination>: View {
    
    private var viewModel: AnlaesseViewModel
    private let calendar: SeesturmCalendar
    private let canEditEvents: Bool
    private let navigationDestination: (GoogleCalendarEvent) -> N
    private let onManageEvent: (EventManagementMode) -> Void
    
    init(
        viewModel: AnlaesseViewModel,
        calendar: SeesturmCalendar,
        canEditEvents: Bool,
        navigationDestination: @escaping (GoogleCalendarEvent) -> N,
        onManageEvent: @escaping (EventManagementMode) -> Void
    ) {
        self.viewModel = viewModel
        self.calendar = calendar
        self.canEditEvents = canEditEvents
        self.navigationDestination = navigationDestination
        self.onManageEvent = onManageEvent
    }
    
    var body: some View {
        AnlaesseContentView(
            eventsState: viewModel.eventsState,
            calendar: calendar,
            navigationDestination: navigationDestination,
            onRetry: {
                Task {
                    await viewModel.getEvents(isPullToRefresh: false)
                }
            },
            hasMoreEvents: viewModel.hasMoreEvents,
            eventsLastUpdated: viewModel.lastUpdated,
            onFetchMoreEvents: {
                Task {
                    await viewModel.getMoreEvents()
                }
            },
            canEditEvents: canEditEvents,
            onManageEvent: onManageEvent
            
        )
        .task {
            if viewModel.eventsState.taskShouldRun {
                await viewModel.getEvents(isPullToRefresh: false)
            }
        }
        .refreshable {
            await Task {
                await viewModel.getEvents(isPullToRefresh: true)
            }.value
        }
    }
}

private struct AnlaesseContentView<N: NavigationDestination>: View {
    
    private let eventsState: InfiniteScrollUiState<[GoogleCalendarEvent]>
    private let calendar: SeesturmCalendar
    private let navigationDestination: (GoogleCalendarEvent) -> N
    private let onRetry: () -> Void
    private let hasMoreEvents: Bool
    private let eventsLastUpdated: String
    private let onFetchMoreEvents: () -> Void
    private let canEditEvents: Bool
    private let onManageEvent: (EventManagementMode) -> Void
    
    init(
        eventsState: InfiniteScrollUiState<[GoogleCalendarEvent]>,
        calendar: SeesturmCalendar,
        navigationDestination: @escaping (GoogleCalendarEvent) -> N,
        onRetry: @escaping () -> Void,
        hasMoreEvents: Bool,
        eventsLastUpdated: String,
        onFetchMoreEvents: @escaping () -> Void,
        canEditEvents: Bool,
        onManageEvent: @escaping (EventManagementMode) -> Void
    ) {
        self.eventsState = eventsState
        self.calendar = calendar
        self.navigationDestination = navigationDestination
        self.onRetry = onRetry
        self.hasMoreEvents = hasMoreEvents
        self.eventsLastUpdated = eventsLastUpdated
        self.onFetchMoreEvents = onFetchMoreEvents
        self.canEditEvents = canEditEvents
        self.onManageEvent = onManageEvent
    }
    
    var body: some View {
        List {
            Group {
                switch eventsState {
                case .loading(_):
                    ForEach(0..<3) { headerIndex in
                        Section {
                            ForEach(0..<3) { index in
                                AnlassLoadingCardView()
                                    .id("AnlässeLoadingCell\(headerIndex)\(index)")
                                    .padding(.top, index == 0 ? 16 : 0)
                            }
                        } header: {
                            BasicStickyHeader(title: "August XXXX")
                                .id("AnlässeLoadingHeader\(headerIndex)")
                                .redacted(reason: .placeholder)
                                .loadingBlinking()
                        }
                    }
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .sync(action: onRetry)
                    )
                    .id("AnlässeErrorCell")
                    .padding(.vertical)
                case .success(let events, let subState):
                    if events.isEmpty {
                        Text("Keine bevorstehenden Anlässe")
                            .id("AnlässeEmptyCell")
                            .padding(.horizontal)
                            .padding(.vertical, 75)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(Color.secondary)
                    }
                    else {
                        ForEach(events.groupedByMonthAndYear, id: \.0) { startDate, events in
                            let title = DateTimeUtil.shared.formatDate(
                                date: startDate,
                                format: "MMMM yyyy",
                                timeZone: TimeZone(identifier: "Europe/Zurich")!,
                                type: .absolute
                            )
                            Section {
                                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                    AnlassCardView(
                                        event: event,
                                        calendar: calendar
                                    )
                                    .id("AnlässeCell\(event.id)")
                                    .padding(.top, index == 0 ? 16 : 0)
                                    .background(
                                        NavigationLink(
                                            value: navigationDestination(event)
                                        ) {
                                            EmptyView()
                                        }
                                            .opacity(0)
                                    )
                                }
                            } header: {
                                BasicStickyHeader(title: title)
                                    .id("AnlässeHeader\(startDate)")
                            }
                        }
                        if hasMoreEvents {
                            switch subState {
                            case .loading, .success:
                                AnlassLoadingCardView()
                                    .id("AnlässeLoadingMoreCell\(events.count)")
                                    .onAppear {
                                        if subState.infiniteScrollTaskShouldRun {
                                            onFetchMoreEvents()
                                        }
                                    }
                            case .error(let message):
                                ErrorCardView(
                                    errorDescription: message,
                                    action: .sync(action: onFetchMoreEvents)
                                )
                                .id("AnlässeLoadingMoreErrorCell")
                                .padding(.bottom)
                            }
                        }
                        Text("Stand Kalender: \(eventsLastUpdated)\n(Alle gezeigten Zeiten in MEZ/MESZ)")
                            .id("AnlässeKalenderStandFooter")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .padding()
                            .padding(.bottom)
                    }
                }
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollDisabled(eventsState.scrollingDisabled)
        .navigationTitle(calendar.isLeitungsteam ? "Termine Leitungsteam" : "Anlässe")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.customBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CalendarSubscriptionButton(calendar: calendar)
            }
            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed, placement: .topBarTrailing)
            }
            if canEditEvents {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onManageEvent(.insert)
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                    }
                }
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .loading(subState: .loading),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: false,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: false,
            onManageEvent: { _ in }
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .error(message: "Schwerer Fehler"),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: false,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: false,
            onManageEvent: { _ in }
        )
    }
}
#Preview("Empty") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .success(data: [], subState: .success),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: false,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: false,
            onManageEvent: { _ in }
        )
    }
}
#Preview("Success with more posts") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .success(
                data: [
                    DummyData.oneDayEvent,
                    DummyData.multiDayEvent,
                    DummyData.allDayOneDayEvent,
                    DummyData.allDayMultiDayEvent
                ],
                subState: .loading
            ),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: true,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: false,
            onManageEvent: { _ in }
        )
    }
}
#Preview("Success with more posts error") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .success(
                data: [
                    DummyData.oneDayEvent,
                    DummyData.multiDayEvent,
                    DummyData.allDayOneDayEvent,
                    DummyData.allDayMultiDayEvent
                ],
                subState: .error(message: "Schwerer Fehler")
            ),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: true,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: true,
            onManageEvent: { _ in }
        )
    }
}
#Preview("Success without more posts") {
    NavigationStack(path: .constant(NavigationPath())) {
        AnlaesseContentView(
            eventsState: .success(
                data: [
                    DummyData.oneDayEvent,
                    DummyData.multiDayEvent,
                    DummyData.allDayOneDayEvent,
                    DummyData.allDayMultiDayEvent
                ],
                subState: .success
            ),
            calendar: .termine,
            navigationDestination: { _ in HomeNavigationDestination.pushNotifications},
            onRetry: {},
            hasMoreEvents: false,
            eventsLastUpdated: "",
            onFetchMoreEvents: {},
            canEditEvents: true,
            onManageEvent: { _ in }
        )
    }
}
