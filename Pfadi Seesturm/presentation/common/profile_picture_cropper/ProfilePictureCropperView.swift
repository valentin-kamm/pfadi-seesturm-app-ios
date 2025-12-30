//
//  ProfilePictureCropperView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

import SwiftUI

struct ProfilePictureCropperView: View {
    
    private let image: UIImage
    private let viewSize: CGSize
    private let onCrop: (ProfilePicture) -> Void
    private let onCancel: () -> Void
    private let maskWidthMultiplier: CGFloat
    private let maxMagnificationScale: CGFloat
    
    init(
        image: UIImage,
        viewSize: CGSize,
        onCrop: @escaping (ProfilePicture) -> Void,
        onCancel: @escaping () -> Void,
        maskWidthMultiplier: CGFloat = 0.9,
        maxMagnificationScale: CGFloat = 5.0
    ) {
        self.image = image
        self.viewSize = viewSize
        self.onCrop = onCrop
        self.onCancel = onCancel
        self.maskWidthMultiplier = maskWidthMultiplier
        self.maxMagnificationScale = maxMagnificationScale
    }
    
    var body: some View {
        
        let maskDiameter = min(
            viewSize.width * maskWidthMultiplier,
            viewSize.height * maskWidthMultiplier
        )
        let imageSizeInView = viewSize.imageFitSize(for: image.aspectRatio)
        let initialZoomScale = maskDiameter / min(imageSizeInView.width, imageSizeInView.height)
        let maxScale = max(
            maxMagnificationScale,
            initialZoomScale
        )
        let identity = ProfilePictureCropperIdentity(
            maskDiameter: maskDiameter,
            imageSizeInView: imageSizeInView,
            maxScale: maxScale,
            initialScale: initialZoomScale
        )
        
        ProfilePictureCropperIntermediateView(
            image: image,
            maskDiameter: maskDiameter,
            imageSizeInView: imageSizeInView,
            maxScale: maxScale,
            initialScale: initialZoomScale,
            onCrop: onCrop,
            onCancel: onCancel
        )
        .id(identity)
    }
}

private struct ProfilePictureCropperIntermediateView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfilePictureCropperViewModel
    @State private var croppingState: UiState<ProfilePicture> = .loading(subState: .idle)
    
    private let image: UIImage
    private let onCrop: (ProfilePicture) -> Void
    private let onCancel: () -> Void
    
    init(
        image: UIImage,
        maskDiameter: CGFloat,
        imageSizeInView: CGSize,
        maxScale: CGFloat,
        initialScale: CGFloat,
        onCrop: @escaping (ProfilePicture) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.image = image
        self.onCrop = onCrop
        self.onCancel = onCancel
        
        self.viewModel = ProfilePictureCropperViewModel(
            imageSizeInView: imageSizeInView,
            maxMagnificationScale: maxScale,
            maskDiameter: maskDiameter,
            initialZoomScale: initialScale
        )
    }
    
    var body: some View {
        ProfilePictureCropperContentView(
            image: image,
            scale: viewModel.scale,
            offset: viewModel.offset,
            maskSize: viewModel.maskSize,
            onCancel: onCancel,
            onCrop: {
                Task {
                    await cropImage()
                }
            },
            magnificationGesture: magnificationGesture,
            dragGesture: dragGesture,
            isCropping: croppingState.isLoading
        )
            .customSnackbar(
                show: showErrorSnackbarBinding,
                type: .error,
                message: "Das Bild konnte nicht zugeschnitten werden. Versuche es erneut.",
                dismissAutomatically: true,
                allowManualDismiss: true
            )
    }
}

private struct ProfilePictureCropperContentView<M: Gesture, D: Gesture>: View {
    
    @Environment(\.dismiss) private var dismiss
    
    private let image: UIImage
    private let scale: CGFloat
    private let offset: CGSize
    private let maskSize: CGSize
    private let onCancel: () -> Void
    private let onCrop: () -> Void
    private let magnificationGesture: M
    private let dragGesture: D
    private let isCropping: Bool
    
    init(
        image: UIImage,
        scale: CGFloat,
        offset: CGSize,
        maskSize: CGSize,
        onCancel: @escaping () -> Void,
        onCrop: @escaping () -> Void,
        magnificationGesture: M,
        dragGesture: D,
        isCropping: Bool
    ) {
        self.image = image
        self.scale = scale
        self.offset = offset
        self.maskSize = maskSize
        self.onCancel = onCancel
        self.onCrop = onCrop
        self.magnificationGesture = magnificationGesture
        self.dragGesture = dragGesture
        self.isCropping = isCropping
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
            Canvas { context, size in
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.5)))
                context.blendMode = .clear
                context.fill(Path(ellipseIn: CGRect(
                    x: (size.width - maskSize.width) / 2,
                    y: (size.height - maskSize.height) / 2,
                    width: maskSize.width,
                    height: maskSize.height
                )), with: .color(.white))
            }
            .compositingGroup()
            VStack(alignment: .center) {
                Text("Bewegen und skalieren")
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                HStack(alignment: .center) {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: {
                            dismiss()
                            onCancel()
                        }),
                        title: "Abbrechen",
                        colors: .custom(contentColor: .white, buttonColor: .clear)
                    )
                    Spacer()
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: onCrop),
                        title: "Auswählen",
                        colors: .custom(contentColor: .white, buttonColor: .clear),
                        isLoading: isCropping
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.all)
            .padding(32)
            .padding(.top, 48)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(dragGesture)
        .disabled(isCropping)
    }
}

private struct ProfilePictureCropperIdentity: Hashable {
    let maskDiameter: CGFloat
    let imageSizeInView: CGSize
    let maxScale: CGFloat
    let initialScale: CGFloat
}

extension ProfilePictureCropperIntermediateView {
    
    private var showErrorSnackbarBinding: Binding<Bool> {
        Binding(
            get: {
                self.croppingState.isError
            },
            set: { isShown in
                if !isShown {
                    withAnimation {
                        self.croppingState = .loading(subState: .idle)
                    }
                }
            }
        )
    }
    
    private func cropImage() async {
        
        withAnimation {
            croppingState = .loading(subState: .loading)
        }
        
        try? await Task.sleep(nanoseconds: 1000000000)
        let result = await viewModel.cropToCircle(image: image)
        
        switch result {
        case .error(_):
            withAnimation {
                croppingState = .error(message: "Das Bild konnte nicht zugeschnitten werden. Versuche es erneut.")
            }
        case .success(let d):
            onCrop(d)
            dismiss()
            withAnimation {
                croppingState = .loading(subState: .idle)
            }
        }
    }
    
    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let scaledValue = value.magnification
                let maxScaledValues = viewModel.calculateMagnificationGestureMaxValues()
                viewModel.scale = min(
                    max(scaledValue * viewModel.lastScale, maxScaledValues.0),
                    maxScaledValues.1
                )
                updateOffset()
            }
            .onEnded { _ in
                viewModel.lastScale = viewModel.scale
                viewModel.lastOffset = viewModel.offset
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let maxOffsetPoint = viewModel.calculateDragGestureMax()
                let newX = min(
                    max(value.translation.width + viewModel.lastOffset.width, -maxOffsetPoint.x),
                    maxOffsetPoint.x
                )
                let newY = min(
                    max(value.translation.height + viewModel.lastOffset.height, -maxOffsetPoint.y),
                    maxOffsetPoint.y
                )
                viewModel.offset = CGSize(width: newX, height: newY)
            }
            .onEnded { _ in
                viewModel.lastOffset = viewModel.offset
            }
    }
    
    private func updateOffset() {
        
        let maxOffsetPoint = viewModel.calculateDragGestureMax()
        let newX = min(
            max(viewModel.offset.width, -maxOffsetPoint.x),
            maxOffsetPoint.x
        )
        let newY = min(
            max(viewModel.offset.height, -maxOffsetPoint.y),
            maxOffsetPoint.y
        )
        viewModel.offset = CGSize(width: newX, height: newY)
        viewModel.lastOffset = viewModel.offset
    }
}

#Preview {
    
    let image = UIImage(named: "onboarding_welcome_image")!
    
    GeometryReader { geometry in
        ProfilePictureCropperIntermediateView(
            image: image,
            maskDiameter: 0.9 * geometry.size.width,
            imageSizeInView: geometry.size.imageFitSize(for: image.aspectRatio),
            maxScale: 5.0,
            initialScale: 1.0,
            onCrop: { _ in },
            onCancel: {}
        )
    }
    .ignoresSafeArea()
}
