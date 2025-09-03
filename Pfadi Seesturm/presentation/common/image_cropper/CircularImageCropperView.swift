//
//  CircularImageCropperView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.08.2025.
//

import SwiftUI

struct CircularImageCropperView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var croppingState: UiState<JPGData> = .loading(subState: .idle)
    
    @State private var viewModel: CircularImageCropperViewModel
    private let image: JPGData
    private let viewSize: CGSize
    private let onCrop: (JPGData) -> Void
    private let onCancel: () -> Void
    private let maskWidthMultiplier: CGFloat
    private let maxMagnificationScale: CGFloat
    
    init(
        image: JPGData,
        viewSize: CGSize,
        onCrop: @escaping (JPGData) -> Void,
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
        let imageSizeInView = viewSize.imageFitSize(for: image.originalUiImage.aspectRatio)
        let initialZoomScale = maskDiameter / min(imageSizeInView.width, imageSizeInView.height)
        let maxScale = max(
            maxMagnificationScale,
            initialZoomScale
        )
        
        self.maxMagnificationScale = maxScale
        self.viewModel = CircularImageCropperViewModel(
            imageSizeInView: imageSizeInView,
            maxMagnificationScale: maxScale,
            maskDiameter: maskDiameter,
            initialZoomScale: initialZoomScale
        )
    }
    
    private var showSnackbarBinding: Binding<Bool> {
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
            Image(uiImage: image.originalUiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .opacity(0.5)
            Image(uiImage: image.originalUiImage)
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
                        isLoading: croppingState.isActuallyLoading
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(32)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .simultaneousGesture(magnificationGesture)
        .simultaneousGesture(dragGesture)
        .disabled(croppingState.isActuallyLoading)
        .customSnackbar(
            show: showSnackbarBinding,
            type: .error,
            message: "Das Bild konnte nicht zugeschnitten werden. Versuche es erneut.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
}

extension CircularImageCropperView {
    
    private func cropImage() async {
        
        await MainActor.run {
            withAnimation {
                croppingState = .loading(subState: .loading)
            }
        }
        
        let result = await Task.detached(priority: .userInitiated) {
            try! await Task.sleep(nanoseconds: 1000000000)
            return await viewModel.cropToCircle(image: image)
        }.value
        
        await MainActor.run {
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
    }
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let scaledValue = value.magnitude
                let maxScaleValues = viewModel.calculateMagnificationGestureMaxValues()
                viewModel.scale = min(
                    max(scaledValue * viewModel.lastScale, maxScaleValues.0),
                    maxScaleValues.1
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
        CircularImageCropperView(
            image: try! JPGData(from: UIImage(named: "onboarding_welcome_image")!),
            viewSize: geometry.size,
            onCrop: { _ in },
            onCancel: {},
            maskWidthMultiplier: 0.9,
            maxMagnificationScale: 5
        )
    }
}
