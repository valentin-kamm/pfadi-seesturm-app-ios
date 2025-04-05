//
//  PhotoSlider.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI
import Kingfisher

struct PhotoSlider: View {
    
    @Binding var selectedImageIndex: Int
    var images: [WordpressPhoto]
    @State var isShowingShareSheet = false
    @State var imagesToShare: [Int: PhotoForSharing] = [:]
        
    var body: some View {
        NavigationStack {
            Group {
                TabView(selection: $selectedImageIndex) {
                    ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                        if let imageUrl = URL(string: image.original) {
                            GeometryReader {geometry in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                KFImage(imageUrl)
                                    .placeholder { progress in
                                        Rectangle()
                                            .fill(.clear)
                                            .frame(width: width, height: height)
                                            .overlay {
                                                ZStack(alignment: .top) {
                                                    Color.skeletonPlaceholderColor
                                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                        .customLoadingBlinking()
                                                    ProgressView(value: progress.fractionCompleted, total: 1.0)
                                                        .progressViewStyle(.linear)
                                                        .tint(Color.SEESTURM_GREEN)
                                                }
                                                .background(Color.clear)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .aspectRatio(Double(image.width) / Double(image.height), contentMode: .fit)
                                            }
                                    }
                                    .onSuccess { result in
                                        let image = Image(uiImage: result.image as UIImage)
                                        imagesToShare[index] = PhotoForSharing(image: image)
                                    }
                                    .cancelOnDisappear(true)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        else {
                            Color.skeletonPlaceholderColor
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .aspectRatio(Double(image.width) / Double(image.height), contentMode: .fit)
                                .overlay {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.SEESTURM_GREEN)
                                }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let shareImage = imagesToShare[selectedImageIndex] {
                        ShareLink(
                            item: shareImage,
                            preview: SharePreview(
                                "Foto \(selectedImageIndex + 1) von \(images.count)",
                                image: shareImage.image
                            )
                        )
                        .tint(Color.SEESTURM_GREEN)
                    }
                }
            }
            .navigationTitle("\(selectedImageIndex + 1) von \(images.count)")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
        }
    }
    
}

struct PhotoForSharing: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    public var image: Image
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
                id: "279",
                thumbnail: ""
            )
        ),
        gallery: WordpressPhotoGallery(
            title: "Test",
            id: "279",
            thumbnail: ""
        )
    )
}
