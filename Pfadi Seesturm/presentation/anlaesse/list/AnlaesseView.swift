//
//  AnlaesseView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AnlaesseView: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    
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
                    calendar: calendar
                ) { event in
                    AccountNavigationDestination.anlassDetail(inputType: .object(object: event))
                }
            }
            else {
                NavigationStack(path: appState.path(for: .anlässe)) {
                    AnlaesseIntermediateView(
                        viewModel: viewModel,
                        calendar: calendar
                    ) { event in
                        AnlaesseNavigationDestination.detail(inputType: .object(object: event))
                    }
                    .anlaesseNavigationDestinations(
                        wordpressModule: wordpressModule,
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
    private let navigationDestination: (GoogleCalendarEvent) -> N
    
    init(
        viewModel: AnlaesseViewModel,
        calendar: SeesturmCalendar,
        navigationDestination: @escaping (GoogleCalendarEvent) -> N
    ) {
        self.viewModel = viewModel
        self.calendar = calendar
        self.navigationDestination = navigationDestination
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
            }
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
    
    init(
        eventsState: InfiniteScrollUiState<[GoogleCalendarEvent]>,
        calendar: SeesturmCalendar,
        navigationDestination: @escaping (GoogleCalendarEvent) -> N,
        onRetry: @escaping () -> Void,
        hasMoreEvents: Bool,
        eventsLastUpdated: String,
        onFetchMoreEvents: @escaping () -> Void
    ) {
        self.eventsState = eventsState
        self.calendar = calendar
        self.navigationDestination = navigationDestination
        self.onRetry = onRetry
        self.hasMoreEvents = hasMoreEvents
        self.eventsLastUpdated = eventsLastUpdated
        self.onFetchMoreEvents = onFetchMoreEvents
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                switch eventsState {
                case .loading:
                    Section(header:
                                BasicStickyHeader(title: "August 2025")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    ) {
                        ForEach(0..<2) { index in
                            AnlassLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                    Section(header:
                                BasicStickyHeader(title: "September 2025")
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    ) {
                        ForEach(0..<7) { index in
                            AnlassLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .sync(action: onRetry)
                    )
                    .padding(.vertical)
                case .success(let events, let subState):
                    if events.isEmpty {
                        Text("Keine bevorstehenden Anlässe")
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
                                    NavigationLink(value: navigationDestination(event)) {
                                        AnlassCardView(
                                            event: event,
                                            calendar: calendar
                                        )
                                        .padding(.top, index == 0 ? 16 : 0)
                                    }
                                        .foregroundStyle(Color.primary)
                                }
                            } header: {
                                BasicStickyHeader(title: title)
                                    .background(Color.customBackground)
                            }
                        }
                        if hasMoreEvents {
                            switch subState {
                            case .error(let message):
                                ErrorCardView(
                                    errorDescription: message,
                                    action: .sync(action: onFetchMoreEvents)
                                )
                                .padding(.bottom)
                            case .loading, .success:
                                AnlassLoadingCardView()
                                    .onAppear {
                                        if subState.infiniteScrollTaskShouldRun {
                                            onFetchMoreEvents()
                                        }
                                    }
                                    .id(events.count)
                            }
                        }
                        Text("Stand Kalender: \(eventsLastUpdated)\n(Alle gezeigten Zeiten in MEZ/MESZ)")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .padding()
                            .padding(.bottom)
                    }
                }
            }
        }
        .scrollDisabled(eventsState.scrollingDisabled)
        .navigationTitle(calendar.isLeitungsteam ? "Termine Leitungsteam" : "Anlässe")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.customBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CalendarSubscriptionButton(calendar: calendar)
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
            onFetchMoreEvents: {}
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
            onFetchMoreEvents: {}
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
            onFetchMoreEvents: {}
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
            onFetchMoreEvents: {}
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
            onFetchMoreEvents: {}
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
            onFetchMoreEvents: {}
        )
    }
}
