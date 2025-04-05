//
//  PhotosGridView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotosGridView: View {
    
    @StateObject var viewModel: PhotosGridViewModel
    var gallery: WordpressPhotoGallery
    
    // variables that are needed to present the photo slider
    @State var showModal: Bool = false
    @State var selectedImageIndex: Int = 0
    
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                let width = (geometry.size.width - 2 * 2) / 3
                ScrollView {
                    switch viewModel.state {
                    case .loading(_):
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(1..<100) { _ in
                                PhotoGalleryLoadingCell(size: width, withText: false)
                            }
                        }
                    case .error(let message):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: message,
                            asyncRetryAction: {
                                await viewModel.fetchPhotos(isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    case .success(let images):
                        if images.count == 0 {
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
                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(images, id: \.id) { image in
                                    PhotoGalleryCell(
                                        size: width,
                                        thumbnailUrl: image.thumbnail
                                    )
                                    // navigate to photo slider
                                    .onTapGesture {
                                        selectedImageIndex = images.firstIndex(where: { $0.id == image.id }) ?? 0
                                        showModal = true
                                    }
                                }
                            }
                        }
                    }
                }
                .scrollDisabled(viewModel.state.scrollingDisabled)
            }
        }
        .navigationTitle(gallery.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showModal) {
            switch viewModel.state {
            case .success(let images):
                PhotoSlider(
                    selectedImageIndex: $selectedImageIndex,
                    images: images
                )
            default:
                EmptyView()
            }
        }
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchPhotos(isPullToRefresh: false)
            }
        }
    }
}

#Preview {
    PhotosGridView(
        viewModel: PhotosGridViewModel(
            service: PhotosService(
                repository: PhotosRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            album: WordpressPhotoGallery(
                title: "Test",
                id: "256",
                thumbnail: ""
            )
        ),
        gallery: WordpressPhotoGallery(
            title: "Test",
            id: "256",
            thumbnail: ""
        )
    )
}
