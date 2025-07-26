//
//  AktuellView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AktuellView: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    
    @State private var viewModel: AktuellViewModel
    
    init(
        viewModel: AktuellViewModel
    ) {
        self.viewModel = viewModel
    }
            
    var body: some View {
        NavigationStack(path: appState.path(for: .aktuell)) {
            GeometryReader { geometry in
                AktuellContentView(
                    eventsState: viewModel.eventsState,
                    onRetry: {
                        Task {
                            await viewModel.getPosts(isPullToRefresh: false)
                        }
                    },
                    hasMorePosts: viewModel.hasMorePosts,
                    onGetMorePosts: {
                        Task {
                            await viewModel.getMorePosts()
                        }
                    },
                    width: geometry.size.width
                )
                .refreshable {
                    await Task {
                        await viewModel.getPosts(isPullToRefresh: true)
                    }.value
                }
                .task {
                    if viewModel.eventsState.taskShouldRun {
                        await viewModel.getPosts(isPullToRefresh: false)
                    }
                }
                .aktuellNavigationDestinations(
                    wordpressModule: wordpressModule,
                    fcmModule: fcmModule
                )
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

private struct AktuellContentView: View {
    
    private let eventsState: InfiniteScrollUiState<[WordpressPost]>
    private let onRetry: () -> Void
    private let hasMorePosts: Bool
    private let onGetMorePosts: () -> Void
    private let width: CGFloat
    
    init(
        eventsState: InfiniteScrollUiState<[WordpressPost]>,
        onRetry: @escaping () -> Void,
        hasMorePosts: Bool,
        onGetMorePosts: @escaping () -> Void,
        width: CGFloat
    ) {
        self.eventsState = eventsState
        self.onRetry = onRetry
        self.hasMorePosts = hasMorePosts
        self.onGetMorePosts = onGetMorePosts
        self.width = width
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                switch eventsState {
                case .loading(_):
                    Section {
                        ForEach(0..<4) {index in
                            AktuellLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    } header: {
                        BasicStickyHeader(title: "Pfadijahr 2024")
                            .redacted(reason: .placeholder)
                            .loadingBlinking()
                    }
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .sync(action: onRetry)
                    )
                    .padding(.vertical)
                case .success(let data, let subState):
                    ForEach(data.groupedByYear, id: \.0) { year, posts in
                        Section {
                            ForEach(Array(posts.enumerated()), id: \.element.id) { index, post in
                                NavigationLink(value: AktuellNavigationDestination.detail(inputType: .object(object: post))) {
                                    AktuellCardView(
                                        post: post,
                                        width: width
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
                    if hasMorePosts {
                        switch subState {
                        case .loading, .success:
                            AktuellLoadingCardView()
                            .onAppear {
                                if subState.infiniteScrollTaskShouldRun {
                                    onGetMorePosts()
                                }
                            }
                            .id(data.count)
                        case .error(let message):
                            ErrorCardView(
                                errorDescription: message,
                                action: .sync(action: onGetMorePosts)
                            )
                            .padding(.bottom)
                        }
                    }
                }
            }
        }
        .navigationTitle("Aktuell")
        .navigationBarTitleDisplayMode(.large)
        .scrollDisabled(eventsState.scrollingDisabled)
        .background(Color.customBackground)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AktuellNavigationDestination.pushNotifications) {
                    Image(systemName: "bell.badge")
                }
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            AktuellContentView(
                eventsState: .loading(subState: .loading),
                onRetry: {},
                hasMorePosts: true,
                onGetMorePosts: {},
                width: geometry.size.width
            )
        }
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            AktuellContentView(
                eventsState: .error(message: "Schwerer Fehler"),
                onRetry: {},
                hasMorePosts: true,
                onGetMorePosts: {},
                width: geometry.size.width
            )
        }
    }
}
#Preview("Success with more posts available") {
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            AktuellContentView(
                eventsState: .success(
                    data: [
                        DummyData.aktuellPost1,
                        DummyData.aktuellPost2
                    ],
                    subState: .loading
                ),
                onRetry: {},
                hasMorePosts: true,
                onGetMorePosts: {},
                width: geometry.size.width
            )
        }
    }
}
#Preview("Success with more posts error") {
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            AktuellContentView(
                eventsState: .success(
                    data: [
                        DummyData.aktuellPost1,
                        DummyData.aktuellPost2
                    ],
                    subState: .error(message: "Schwerer Fehler")
                ),
                onRetry: {},
                hasMorePosts: true,
                onGetMorePosts: {},
                width: geometry.size.width
            )
        }
    }
}
#Preview("Success without more posts") {
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            AktuellContentView(
                eventsState: .success(
                    data: [
                        DummyData.aktuellPost1,
                        DummyData.aktuellPost2
                    ],
                    subState: .success
                ),
                onRetry: {},
                hasMorePosts: false,
                onGetMorePosts: {},
                width: geometry.size.width
            )
        }
    }
}
