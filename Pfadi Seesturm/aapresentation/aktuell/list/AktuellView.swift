//
//  AktuellView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import SwiftData
import FirebaseFunctions

struct AktuellView: View {
        
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @StateObject var viewModel: AktuellViewModel
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
            
    var body: some View {
        NavigationStack(path: appState.aktuellNavigationPathBinding) {
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        switch viewModel.state.result {
                        case .loading(_):
                            Section(header:
                                        BasicStickyHeader(title: "Pfadijahr 2024")
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                            ) {
                                ForEach(0..<4) {index in
                                    AktuellSkeletonCardView()
                                        .padding(.top, index == 0 ? 16 : 0)
                                }
                            }
                        case .error(let message):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: message,
                                asyncRetryAction: {
                                    await viewModel.getPosts(isPullToRefresh: false)
                                }
                            )
                            .padding(.vertical)
                        case .success(let data, let subState):
                            ForEach(data.groupedByYear, id: \.0) { year, posts in
                                Section {
                                    ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                                        NavigationLink(value: AktuellNavigationDestination.detail(inputType: .object(object: post))) {
                                            AktuellCardView(
                                                post: post,
                                                width: geometry.size.width
                                            )
                                            .padding(.top, index == 0 ? 16 : 0)
                                        }
                                        .foregroundStyle(Color.primary)
                                    }
                                } header: {
                                    BasicStickyHeader(title: "Pfadijahr \(year)")
                                        .background(Color.customBackground)
                                }
                            }
                            if viewModel.hasMorePosts {
                                switch subState {
                                case .loading, .success:
                                    AktuellSkeletonCardView()
                                        .onAppear {
                                            if subState.infiniteScrollTaskShouldRun {
                                                Task {
                                                    await viewModel.getMorePosts()
                                                }
                                            }
                                        }
                                case .error(let message):
                                    CardErrorView(
                                        errorTitle: "Es konnten keine weiteren Posts geladen werden",
                                        errorDescription: message,
                                        asyncRetryAction: {
                                            await viewModel.getMorePosts()
                                        }
                                    )
                                    .padding(.bottom)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Aktuell")
                .navigationBarTitleDisplayMode(.large)
                .scrollDisabled(viewModel.state.result.scrollingDisabled)
                .background(Color.customBackground)
                .refreshable {
                    await Task {
                        await viewModel.getPosts(isPullToRefresh: true)
                    }.value
                }
                .task {
                    if viewModel.state.result.taskShouldRun {
                        await viewModel.getPosts(isPullToRefresh: false)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                            Image(systemName: "bell.badge")
                        }
                    }
                }
                .aktuellNavigationDestinations(
                    wordpressModule: wordpressModule,
                    fcmModule: fcmModule,
                    modelContext: modelContext
                )
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview() {
    AktuellView(
        viewModel: AktuellViewModel(
            service: AktuellService(
                repository: AktuellRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        )
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
