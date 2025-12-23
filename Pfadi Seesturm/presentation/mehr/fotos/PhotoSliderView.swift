//
//  PhotoSliderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI
import Kingfisher

struct PhotoSliderView: View {
    
    private let mode: PhotoSliderViewMode
    @State private var imageIndex: Int
    @State private var toolbarVisibility: Visibility = .visible
    
    init(
        mode: PhotoSliderViewMode
    ) {
        self.mode = mode
        switch mode {
        case .single(_):
            self._imageIndex = State(initialValue: 0)
        case .multi(_, let initialIndex):
            self._imageIndex = State(initialValue: initialIndex)
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                PhotoSliderContentView(
                    mode: mode,
                    imageIndex: $imageIndex,
                    screenSize: geometry.size
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
        // allow landscape for this view only
        .unlockRotation()
        .ignoresSafeArea()
        .background(Color.customBackground)
    }
}

private struct PhotoSliderContentView: View {
    
    private let mode: PhotoSliderViewMode
    @Binding private var imageIndex: Int
    private let screenSize: CGSize
    
    init(
        mode: PhotoSliderViewMode,
        imageIndex: Binding<Int>,
        screenSize: CGSize
    ) {
        self.mode = mode
        self._imageIndex = imageIndex
        self.screenSize = screenSize
    }
    
    var body: some View {
        switch mode {
        case .single(let image):
            Group {
                if let url = image.url {
                    ZoomableContainer(
                        entireViewSize: screenSize,
                        imageAspectRatio: image.aspectRatio
                    ) {
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
                            .aspectRatio(image.aspectRatio, contentMode: .fit)
                    }
                }
                else {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(image.aspectRatio, contentMode: .fit)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
        case .multi(let images, _):
            TabView(selection: $imageIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                                        
                    if let url = image.url {
                        
                        ZoomableContainer(
                            entireViewSize: screenSize,
                            imageAspectRatio: image.aspectRatio
                        ) {
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
                                .aspectRatio(image.aspectRatio, contentMode: .fit)
                            }
                            .tag(index)
                    }
                    else {
                        Rectangle()
                            .fill(Color.skeletonPlaceholderColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .aspectRatio(image.aspectRatio, contentMode: .fit)
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
            .navigationTitle("\(imageIndex + 1) von \(images.count)")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customBackground)
        }
    }
}

    
enum PhotoSliderViewMode {
    case single(image: PhotoSliderViewItem)
    case multi(images: [PhotoSliderViewItem], initialIndex: Int)
}

#Preview("Multi") {
    
    @Previewable @State var index: Int = 0
    
    let wordpressImages = [
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
    ]
    
    let images: [PhotoSliderViewItem] = wordpressImages.map { photo in
        PhotoSliderViewItem(from: photo)
    }
    
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            PhotoSliderContentView(
                mode: .multi(
                    images: images,
                    initialIndex: 0
                ),
                imageIndex: $index,
                screenSize: geometry.size
            )
        }
    }
}

#Preview("Single") {
    
    let wordpressPhoto = WordpressPhoto(
        id: UUID(),
        thumbnailUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
        originalUrl: "https://ih1.redbubble.net/image.1742264708.3656/flat,750x1000,075,t.u1.jpg",
        orientation: "",
        height: 100,
        width: 400
    )
    let item = PhotoSliderViewItem(from: wordpressPhoto)
    
    NavigationStack(path: .constant(NavigationPath())) {
        GeometryReader { geometry in
            PhotoSliderContentView(
                mode: .single(image: item),
                imageIndex: .constant(0),
                screenSize: geometry.size
            )
        }
    }
}
