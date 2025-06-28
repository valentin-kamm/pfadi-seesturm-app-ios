//
//  GalleriesView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct GalleriesView<D: NavigationDestination>: View {
    
    private var viewModel: GalleriesViewModel
    private let navigationDestination: (WordpressPhotoGallery) -> D
    private let type: PhotoGalleriesType
    private let forceReload: Bool
    
    init(
        viewModel: GalleriesViewModel,
        navigationDestination: @escaping (WordpressPhotoGallery) -> D,
        type: PhotoGalleriesType,
        forceReload: Bool
    ) {
        self.viewModel = viewModel
        self.navigationDestination = navigationDestination
        self.type = type
        self.forceReload = forceReload
    }
    
    private var navigationTitle: String {
        switch type {
        case .pfadijahre:
            return "Fotos"
        case .albums(let pfadijahr):
            return pfadijahr.title
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            GalleriesContentView(
                galleryState: viewModel.galleryState,
                navigationDestination: navigationDestination,
                screenWidth: geometry.size.width,
                navigationTitle: navigationTitle,
                onRetry: {
                    await viewModel.fetchGalleries(isPullToRefresh: false)
                }
            )
        }
        .task {
            if forceReload || viewModel.galleryState.taskShouldRun {
                await viewModel.fetchGalleries(isPullToRefresh: false)
            }
        }
    }
}

private struct GalleriesContentView<D: NavigationDestination>: View {
    
    private let galleryState: UiState<[WordpressPhotoGallery]>
    private let navigationDestination: (WordpressPhotoGallery) -> D
    private let screenWidth: CGFloat
    private let navigationTitle: String
    private let onRetry: () async -> Void
    
    init(
        galleryState: UiState<[WordpressPhotoGallery]>,
        navigationDestination: @escaping (WordpressPhotoGallery) -> D,
        screenWidth: CGFloat,
        navigationTitle: String,
        onRetry: @escaping () async -> Void
    ) {
        self.galleryState = galleryState
        self.navigationDestination = navigationDestination
        self.screenWidth = screenWidth
        self.navigationTitle = navigationTitle
        self.onRetry = onRetry
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    private var columnWidth: CGFloat {
        let desiredWidth = (screenWidth - 3 * 16) / 2
        if desiredWidth < 0 {
            return 0
        }
        return desiredWidth
    }
    
    var body: some View {
        ScrollView {
            switch galleryState {
            case .loading(_):
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(1..<50) { _ in
                        PhotoGalleryLoadingCell(
                            size: columnWidth,
                            withText: true
                        )
                    }
                }
                .padding()
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.vertical)
            case .success(let galleries):
                if galleries.isEmpty {
                    Text("Keine Fotos")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.vertical, 60)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(galleries.reversed()) { gallery in
                            NavigationLink(value: navigationDestination(gallery)) {
                                PhotoGalleryCell(
                                    size: columnWidth,
                                    thumbnailUrl: gallery.thumbnailUrl,
                                    title: gallery.title
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .scrollDisabled(galleryState.scrollingDisabled)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Loading") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            GalleriesContentView(
                galleryState: .loading(subState: .loading),
                navigationDestination: { _ in MehrNavigationDestination.dokumente },
                screenWidth: geometry.size.width,
                navigationTitle: "Fotos",
                onRetry: {}
            )
        }
    }
}
#Preview("Error") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            GalleriesContentView(
                galleryState: .error(message: "Schwerer Fehler"),
                navigationDestination: { _ in MehrNavigationDestination.dokumente },
                screenWidth: geometry.size.width,
                navigationTitle: "Fotos",
                onRetry: {}
            )
        }
    }
}
#Preview("Empty") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            GalleriesContentView(
                galleryState: .success(data: []),
                navigationDestination: { _ in MehrNavigationDestination.dokumente },
                screenWidth: geometry.size.width,
                navigationTitle: "Fotos",
                onRetry: {}
            )
        }
    }
}
#Preview("Success") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            GalleriesContentView(
                galleryState: .success(data: [
                    WordpressPhotoGallery(
                        title: "Pfadijahr 2023",
                        id: "25",
                        thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
                    ),
                    WordpressPhotoGallery(
                        title: "Pfadijahr 2023",
                        id: "26",
                        thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
                    ),
                    WordpressPhotoGallery(
                        title: "Pfadijahr 2023",
                        id: "27",
                        thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
                    )
                ]),
                navigationDestination: { _ in MehrNavigationDestination.dokumente },
                screenWidth: geometry.size.width,
                navigationTitle: "Fotos",
                onRetry: {}
            )
        }
    }
}
