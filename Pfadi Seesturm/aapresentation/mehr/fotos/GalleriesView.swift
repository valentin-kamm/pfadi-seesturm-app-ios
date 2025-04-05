//
//  GalleriesView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct GalleriesView: View {
    
    @StateObject var viewModel: GalleriesViewModel
    let pfadijahr: WordpressPhotoGallery
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                let width = (geometry.size.width - 3 * 16) / 2
                ScrollView {
                    switch viewModel.state {
                    case .loading(_):
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(1..<100) { _ in
                                PhotoGalleryLoadingCell(size: width, withText: true)
                            }
                        }
                        .padding()
                    case .error(let message):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: message,
                            asyncRetryAction: {
                                await viewModel.fetchGalleries(isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    case .success(let galleries):
                        if galleries.count == 0 {
                            VStack {
                                Text("Keine Fotos")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(galleries.reversed(), id: \.id) { gallery in
                                    NavigationLink(value: MehrNavigationDestination.photos(album: gallery)) {
                                        PhotoGalleryCell(
                                            size: width,
                                            thumbnailUrl: gallery.thumbnail,
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
                .scrollDisabled(viewModel.state.scrollingDisabled)
            }
        }
        .navigationTitle(pfadijahr.title)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchGalleries(isPullToRefresh: false)
            }
        }
    }
}

#Preview {
    GalleriesView(
        viewModel: GalleriesViewModel(
            service: PhotosService(
                repository: PhotosRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            pfadijahr: WordpressPhotoGallery(
                title: "Pfadijahr 2023",
                id: "25",
                thumbnail: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
            )
        ),
        pfadijahr: WordpressPhotoGallery(
            title: "Pfadijahr 2023",
            id: "25",
            thumbnail: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
        )
    )
}
