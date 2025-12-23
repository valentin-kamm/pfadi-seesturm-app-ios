//
//  PhotosGridView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotosGridView: View {
    
    @State private var viewModel: PhotosGridViewModel
    private let gallery: WordpressPhotoGallery
    
    init(
        viewModel: PhotosGridViewModel,
        gallery: WordpressPhotoGallery
    ) {
        self.viewModel = viewModel
        self.gallery = gallery
    }
        
    var body: some View {
        GeometryReader { geometry in
            PhotosGridContentView(
                photosState: viewModel.photosState,
                screenWidth: geometry.size.width,
                navigationTitle: gallery.title,
                onRetry: {
                    await viewModel.fetchPhotos(isPullToRefresh: false)
                }
            )
        }
        .task {
            if viewModel.photosState.taskShouldRun {
                await viewModel.fetchPhotos(isPullToRefresh: false)
            }
        }
    }
}

private struct PhotosGridContentView: View {
    
    private let photosState: UiState<[WordpressPhoto]>
    private let screenWidth: CGFloat
    private let navigationTitle: String
    private let onRetry: () async -> Void
    
    @State private var selectedPhoto: WordpressPhoto? = nil
    
    init(
        photosState: UiState<[WordpressPhoto]>,
        screenWidth: CGFloat,
        navigationTitle: String,
        onRetry: @escaping () async -> Void
    ) {
        self.photosState = photosState
        self.screenWidth = screenWidth
        self.navigationTitle = navigationTitle
        self.onRetry = onRetry
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    private var cellWidth: CGFloat {
        let desiredWidth = (screenWidth - 2 * 2) / 3
        if desiredWidth < 0 {
            return 0
        }
        return desiredWidth
    }
    
    var body: some View {
        ScrollView {
            switch photosState {
            case .loading(_):
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(1..<50) { _ in
                        PhotoGalleryLoadingCell(size: cellWidth, withText: false)
                    }
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.vertical)
            case .success(let images):
                if images.isEmpty {
                    Text("Keine Fotos")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding()
                        .padding(.vertical, 60)
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(images) { image in
                            PhotoGalleryCell(
                                size: cellWidth,
                                thumbnailUrl: image.thumbnailUrl
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedPhoto = image
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDisabled(photosState.scrollingDisabled || selectedPhoto != nil)
        .fullScreenCover(item: $selectedPhoto) { photo in
            if case .success(let photos) = photosState, let index = photos.firstIndex(of: photo) {
                NavigationStack(path: .constant(NavigationPath())) {
                    let items = photos.map { photo in
                        PhotoSliderViewItem(from: photo)
                    }
                    PhotoSliderView(
                        mode: .multi(images: items, initialIndex: index)
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Schliessen") {
                                withAnimation {
                                    selectedPhoto = nil
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview("Loading") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            PhotosGridContentView(
                photosState: .loading(subState: .loading),
                screenWidth: geometry.size.width,
                navigationTitle: "Test",
                onRetry: {}
            )
        }
    }
}
#Preview("Error") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            PhotosGridContentView(
                photosState: .error(message: "Schwerer Fehler"),
                screenWidth: geometry.size.width,
                navigationTitle: "Test",
                onRetry: {}
            )
        }
    }
}
#Preview("Empty") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            PhotosGridContentView(
                photosState: .success(data: []),
                screenWidth: geometry.size.width,
                navigationTitle: "Test",
                onRetry: {}
            )
        }
    }
}
#Preview("Success") {
    GeometryReader { geometry in
        NavigationStack(path: .constant(NavigationPath())) {
            PhotosGridContentView(
                photosState: .success(data: [
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "",
                        originalUrl: "",
                        orientation: "",
                        height: 200,
                        width: 200
                    ),
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "",
                        originalUrl: "",
                        orientation: "",
                        height: 200,
                        width: 200
                    ),
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "",
                        originalUrl: "",
                        orientation: "",
                        height: 200,
                        width: 200
                    ),
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "",
                        originalUrl: "",
                        orientation: "",
                        height: 200,
                        width: 200
                    )
                ]),
                screenWidth: geometry.size.width,
                navigationTitle: "Test",
                onRetry: {}
            )
        }
    }
}
