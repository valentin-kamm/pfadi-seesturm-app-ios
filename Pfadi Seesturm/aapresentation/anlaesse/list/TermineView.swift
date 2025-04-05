//
//  TermineView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import FirebaseFunctions

struct TermineView: View {
    
    @StateObject var viewModel: TermineViewModel
    let calendar: SeesturmCalendar
    @EnvironmentObject var appState: AppStateViewModel
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    
    var body: some View {
        if calendar.isLeitungsteam {
            TermineContentView(viewModel: viewModel, calendar: calendar)
        }
        else {
            NavigationStack(path: appState.anlaesseNavigationPathBinding) {
                TermineContentView(viewModel: viewModel, calendar: calendar)
                    .anlaesseNavigationDestinations(
                        wordpressModule: wordpressModule,
                        calendar: calendar
                    )
            }
        }
    }
}

struct TermineContentView: View {
    
    @ObservedObject var viewModel: TermineViewModel
    let calendar: SeesturmCalendar
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                switch viewModel.state.result {
                case .loading:
                    Section(header:
                                BasicStickyHeader(title: "August 2025")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    ) {
                        ForEach(0..<2) { index in
                            TermineLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                    Section(header:
                                BasicStickyHeader(title: "September 2025")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    ) {
                        ForEach(0..<7) { index in
                            TermineLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                case .error(let message):
                    CardErrorView(
                        errorTitle: "Ein Fehler ist aufgetreten",
                        errorDescription: message,
                        asyncRetryAction: {
                            await viewModel.getEvents(isPullToRefresh: false)
                        }
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
                            let title = DateTimeUtil.shared.formatDate(date: startDate, format: "MMMM yyyy", withRelativeDateFormatting: false, timeZone: .current)
                            Section {
                                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                    NavigationLink(value: AnlaesseNavigationDestination.detail(inputType: .object(object: event))) {
                                        TermineCardView(
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
                        if viewModel.hasMoreEvents {
                            switch subState {
                            case .error(let message):
                                CardErrorView(
                                    errorTitle: "Es konnten keine weiteren Termine geladen werden",
                                    errorDescription: message,
                                    asyncRetryAction: {
                                        await viewModel.getEvents(isPullToRefresh: false)
                                    }
                                )
                                .padding(.bottom)
                            case .loading, .success:
                                TermineLoadingCardView()
                                    .onAppear {
                                        if subState.infiniteScrollTaskShouldRun {
                                            Task {
                                                await viewModel.getMoreEvents()
                                            }
                                        }
                                    }
                            }
                        }
                        Text("Stand Kalender: \(viewModel.state.lastUpdated)\n(Alle gezeigten Zeiten in MEZ/MESZ)")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .padding()
                            .padding(.bottom)
                    }
                }
            }
        }
        .background(Color.customBackground)
        .scrollDisabled(viewModel.state.result.scrollingDisabled)
        .navigationTitle(calendar.isLeitungsteam ? "Termine Leitungsteam" : "Anlässe")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIApplication.shared.open(calendar.data.subscriptionUrl)
                }) {
                    Image(systemName: "calendar.badge.plus")
                }
                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
            }
        }
        .task {
            if viewModel.state.result.taskShouldRun {
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

#Preview {
    TermineView(
        viewModel: TermineViewModel(
            service: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            calendar: .termine
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
