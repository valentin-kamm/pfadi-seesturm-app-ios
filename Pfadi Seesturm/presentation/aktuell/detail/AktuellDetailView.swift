//
//  AktuellDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI
import Kingfisher
import RichText

struct AktuellDetailView<D: NavigationDestination>: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    
    @State private var viewModel: AktuellDetailViewModel
    private let pushNotificationsNavigationDestination: D
    
    init(
        viewModel: AktuellDetailViewModel,
        pushNotificationsNavigationDestination: D
    ) {
        self.viewModel = viewModel
        self.pushNotificationsNavigationDestination = pushNotificationsNavigationDestination
    }
    
    var body: some View {
        AktuellDetailContentView(
            postState: viewModel.postState,
            onRetry: {
                Task{
                    await viewModel.fetchPost()
                }
            },
            pushNotificationsNavigationDestination: pushNotificationsNavigationDestination
        )
        .task {
            if viewModel.postState.taskShouldRun {
                await viewModel.fetchPost()
            }
        }
    }
}

private struct AktuellDetailContentView<D: NavigationDestination>: View {
    
    private let postState: UiState<WordpressPost>
    private let onRetry: () -> Void
    private let pushNotificationsNavigationDestination: D
    
    init(
        postState: UiState<WordpressPost>,
        onRetry: @escaping () -> Void,
        pushNotificationsNavigationDestination: D
    ) {
        self.postState = postState
        self.onRetry = onRetry
        self.pushNotificationsNavigationDestination = pushNotificationsNavigationDestination
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                switch postState {
                case .loading(_):
                    VStack(spacing: 16) {
                        Rectangle()
                            .fill(Color.skeletonPlaceholderColor)
                            .aspectRatio(4/3, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .loadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(2)
                            .padding(.horizontal)
                            .font(.title)
                            .fontWeight(.bold)
                            .redacted(reason: .placeholder)
                            .loadingBlinking()
                        Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                            .padding(.bottom, -100)
                            .padding(.horizontal)
                            .font(.body)
                            .redacted(reason: .placeholder)
                            .loadingBlinking()
                    }
                case .error(let message):
                    ErrorCardView(
                        errorDescription: message,
                        action: .sync(action: onRetry)
                    )
                    .padding(.vertical)
                case .success(let post):
                    VStack(alignment: .leading, spacing: 16) {
                        if let image = URL(string: post.imageUrl) {
                            KFImage(image)
                                .placeholder { progress in
                                    ZStack(alignment: .top) {
                                        Rectangle()
                                            .fill(Color.skeletonPlaceholderColor)
                                            .aspectRatio(post.imageAspectRatio, contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .loadingBlinking()
                                        ProgressView(value: progress.fractionCompleted, total: Double(1.0))
                                            .progressViewStyle(.linear)
                                            .tint(Color.SEESTURM_GREEN)
                                    }
                                }
                                .resizable()
                                .scaledToFill()
                                .aspectRatio(post.imageAspectRatio, contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.width / post.imageAspectRatio)
                                .clipped()
                        }
                        Text(post.titleDecoded)
                            .padding(.horizontal)
                            .multilineTextAlignment(.leading)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.top, URL(string: post.imageUrl) == nil ? 16 : 0)
                        Label(post.publishedFormatted, systemImage: "calendar")
                            .padding(.horizontal)
                            .lineLimit(1)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .labelStyle(.titleAndIcon)
                        RichText(html: post.content)
                            .loadingTransition(.none)
                            .linkOpenType(.SFSafariView())
                            .placeholder(content: {
                                Text(Constants.PLACEHOLDER_TEXT)
                                    .padding(.bottom, -100)
                                    .padding(.horizontal)
                                    .font(.body)
                                    .redacted(reason: .placeholder)
                                    .loadingBlinking()
                            })
                            .customCSS("html * { background-color: transparent;}")
                            .padding([.horizontal, .bottom])
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .disabled(postState.scrollingDisabled)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: pushNotificationsNavigationDestination) {
                    Image(systemName: "bell.badge")
                }
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktuellDetailContentView(
            postState: .loading(subState: .loading),
            onRetry: {},
            pushNotificationsNavigationDestination: AktuellNavigationDestination.pushNotifications
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktuellDetailContentView(
            postState: .error(message: "Schwerer Fehler"),
            onRetry: {},
            pushNotificationsNavigationDestination: AktuellNavigationDestination.pushNotifications
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktuellDetailContentView(
            postState: .success(data: DummyData.aktuellPost1),
            onRetry: {},
            pushNotificationsNavigationDestination: AktuellNavigationDestination.pushNotifications
        )
    }
}
