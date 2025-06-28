//
//  PhotoSliderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI
import Kingfisher

struct PhotoSliderView: View {
    
    private let images: [WordpressPhoto]
    @State private var imageIndex: Int
    @State private var toolbarVisibility: Visibility = .visible
    
    init(
        images: [WordpressPhoto],
        initialImageIndex: Int
    ) {
        self.images = images
        self._imageIndex = State(initialValue: initialImageIndex)
    }
    
    var body: some View {
        GeometryReader { geometry in
            PhotoSliderContentView(
                images: images,
                imageIndex: $imageIndex,
                screenWidth: geometry.size.width,
                screenHeight: geometry.size.height
            )
            .toolbar(toolbarVisibility)
            .onTapGesture {
                withAnimation {
                    if case .visible = toolbarVisibility {
                        toolbarVisibility = .hidden
                    }
                    else {
                        toolbarVisibility = .visible
                    }
                }
            }
        }
    }
}

private struct PhotoSliderContentView: View {
    
    private let images: [WordpressPhoto]
    @Binding private var imageIndex: Int
    private let screenWidth: CGFloat
    private let screenHeight: CGFloat
    
    @State private var imagesForSharing: [Int: PhotoForSharing] = [:]
    
    init(
        images: [WordpressPhoto],
        imageIndex: Binding<Int>,
        screenWidth: CGFloat,
        screenHeight: CGFloat
    ) {
        self.images = images
        self._imageIndex = imageIndex
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    
    var body: some View {
        TabView(selection: $imageIndex) {
            ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                if let url = URL(string: image.originalUrl) {
                    KFImage(url)
                        .cancelOnDisappear(true)
                        .placeholder { progress in
                            ZStack(alignment: .top) {
                                Rectangle()
                                    .fill(Color.skeletonPlaceholderColor)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                ProgressView(value: progress.fractionCompleted, total: 1.0)
                                    .progressViewStyle(.linear)
                                    .tint(Color.SEESTURM_GREEN)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(Double(image.width) / Double(image.height), contentMode: .fit)
                        .tag(index)
                }
                else {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(Double(image.width) / Double(image.height), contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                        }
                        .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if let shareImage = imagesForSharing[imageIndex] {
                    ShareLink(
                        item: shareImage,
                        preview: SharePreview(
                            "Foto \(imageIndex + 1) von \(images.count)",
                            image: shareImage.image
                        )
                    )
                    .tint(Color.SEESTURM_GREEN)
                }
            }
        }
        .navigationTitle("\(imageIndex + 1) von \(images.count)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
    }
}

#Preview {
    
    @Previewable @State var index: Int = 0
    
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            PhotoSliderContentView(
                images: [
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
                        originalUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
                        orientation: "",
                        height: 200,
                        width: 200
                    ),
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
                        originalUrl: "",
                        orientation: "",
                        height: 300,
                        width: 100
                    ),
                    WordpressPhoto(
                        id: UUID(),
                        thumbnailUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
                        originalUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
                        orientation: "",
                        height: 100,
                        width: 400
                    )
                ],
                imageIndex: $index,
                screenWidth: geometry.size.width,
                screenHeight: geometry.size.height
            )
        }
    }
}
