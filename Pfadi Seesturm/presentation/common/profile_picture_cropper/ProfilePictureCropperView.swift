//
//  ProfilePictureCropperView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

import SwiftUI

struct ProfilePictureCropperView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var croppingState: UiState<ProfilePicture> = .loading(subState: .idle)
    
    @State private var viewModel: ProfilePictureCropperViewModel
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
        
        self.maxMagnificationScale = maxScale
        self.viewModel = ProfilePictureCropperViewModel(
            imageSizeInView: imageSizeInView,
            maxMagnificationScale: maxScale,
            maskDiameter: maskDiameter,
            initialZoomScale: initialZoomScale
        )
    }
    
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
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .opacity(0.5)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .mask {
                    Circle()
                        .frame(width: viewModel.maskSize.width, height: viewModel.maskSize.height)
                }
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
                        action: .async(action: cropImage),
                        title: "Auswählen",
                        colors: .custom(contentColor: .white, buttonColor: .clear),
                        isLoading: croppingState.isLoading
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(dragGesture)
        .disabled(croppingState.isLoading)
        .customSnackbar(
            show: showErrorSnackbarBinding,
            type: .error,
            message: "Das Bild konnte nicht zugeschnitten werden. Versuche es erneut.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
}

extension ProfilePictureCropperView {
    
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
        MagnificationGesture()
            .onChanged { value in
                let scaledValue = value.magnitude
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
    GeometryReader { geometry in
        ProfilePictureCropperView(
            image: UIImage(named: "onboarding_welcome_image")!,
            viewSize: geometry.size,
            onCrop: { _ in },
            onCancel: {}
        )
    }
}
