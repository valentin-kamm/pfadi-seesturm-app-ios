//
//  PhotoSliderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//
import SwiftUI
import Kingfisher

struct PhotoSliderView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let mode: PhotoSliderViewMode
    @State private var imageIndex: Int
    @State private var toolbarVisibility: Visibility = .visible
    @State private var screenSize: CGSize = .zero
    
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
    
    private var navigationTitle: String {
        switch mode {
        case .single(_):
            ""
        case .multi(let images, _):
            "\(imageIndex + 1) von \(images.count)"
        }
    }
    
    var body: some View {
        
        NavigationStack(path: .constant(NavigationPath())) {
            GeometryReader { geometry in
                PhotoSliderContentView(
                    mode: mode,
                    imageIndex: $imageIndex,
                    screenSize: screenSize
                )
                .onAppear {
                    self.screenSize = geometry.size
                }
                .onChange(of: geometry.size) { _, newValue in
                    self.screenSize = newValue
                }
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
            .ignoresSafeArea()
            .background(Color.customBackground)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar(toolbarVisibility)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schliessen") {
                        dismiss()
                    }
                }
            }
        }
        .unlockRotation()
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
    
    private var scrollBinding: Binding<Int?> {
        Binding(
            get: {
                imageIndex
            },
            set: {
                if let newIndex = $0 {
                    imageIndex = newIndex
                }
            }
        )
    }
    private var images: [PhotoSliderViewItem] {
        switch mode {
        case .single(let image):
            [image]
        case .multi(let images, _):
            images
        }
    }
    private var scrollDisabled: Bool {
        switch mode {
        case .single(_):
            return true
        case .multi(_, _):
            return false
        }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                    Group {
                        if let url = image.url {
                            ZoomableContainer(
                                viewSize: screenSize,
                                contentAspectRatio: image.aspectRatio
                            ) {
                                KFImage(url)
                                    .cancelOnDisappear(true)
                                    .placeholder { progress in
                                        ZStack(alignment: .top) {
                                            Rectangle()
                                                .fill(Color.skeletonPlaceholderColor)
                                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                            ProgressView(value: progress.fractionCompleted, total: 1.0)
                                                .progressViewStyle(.linear)
                                                .tint(Color.SEESTURM_GREEN)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                    }
                                    .resizable()
                                    .aspectRatio(image.aspectRatio, contentMode: .fit)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                            }
                        }
                        else {
                            Rectangle()
                                .fill(Color.skeletonPlaceholderColor)
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
                    .id(index)
                    .containerRelativeFrame(.horizontal)
                }
            }
            .scrollTargetLayout()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: scrollBinding)
        .scrollBounceBehavior(.always)
        .scrollDisabled(scrollDisabled)
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
    
    PhotoSliderView(
        mode: .multi(
            images: images,
            initialIndex: 0
        )
    )
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
    
    PhotoSliderView(mode: .single(image: item))
}
