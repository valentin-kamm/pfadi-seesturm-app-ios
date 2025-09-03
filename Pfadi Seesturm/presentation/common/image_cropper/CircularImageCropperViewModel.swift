//
//  CircularImageCropperViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.08.2025.
//
import SwiftUI
import Observation

@Observable
@MainActor
class CircularImageCropperViewModel {
    
    var maskSize: CGSize
    var scale: CGFloat
    var lastScale: CGFloat
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    
    private let imageSizeInView: CGSize
    private let maxMagnificationScale: CGFloat
    
    init(
        imageSizeInView: CGSize,
        maxMagnificationScale: CGFloat,
        maskDiameter: CGFloat,
        initialZoomScale: CGFloat
    ) {
        self.imageSizeInView = imageSizeInView
        self.maxMagnificationScale = maxMagnificationScale
        self.maskSize = CGSize(width: maskDiameter, height: maskDiameter)
        self.scale = initialZoomScale
        self.lastScale = initialZoomScale
    }
    
    func calculateDragGestureMax() -> CGPoint {
        
        let xLimit = max(0, ((imageSizeInView.width / 2) * scale) - (maskSize.width / 2))
        let yLimit = max(0, ((imageSizeInView.height / 2) * scale) - (maskSize.height / 2))
        return CGPoint(x: xLimit, y: yLimit)
    }
    
    func calculateMagnificationGestureMaxValues() -> (CGFloat, CGFloat) {
        
        let minScale = max(maskSize.width / imageSizeInView.width, maskSize.height / imageSizeInView.height)
        return (minScale, maxMagnificationScale)
    }
    
    func cropToCircle(image: JPGData) -> SeesturmResult<JPGData, LocalError> {
        
        guard let orientedImage = image.originalUiImage.correctlyOriented else {
            return .error(.unknown)
        }
        
        let cropRect = calculateCropRect(orientedImage)
        
        let imageRendererFormat = orientedImage.imageRendererFormat
        imageRendererFormat.opaque = false
        
        let croppedImage = UIGraphicsImageRenderer(
            size: cropRect.size,
            format: imageRendererFormat
        ).image { _ in
            let drawImageRect = CGRect(
                origin: CGPoint(x: -cropRect.origin.x, y: -cropRect.origin.y),
                size: orientedImage.size
            )
            orientedImage.draw(in: drawImageRect)
        }
        
        do {
            let data = try JPGData(from: croppedImage)
            return .success(data)
        }
        catch {
            return .error(.unknown)
        }
    }
    
    private func calculateCropRect(_ orientedImage: UIImage) -> CGRect {
        
        let factor = min(
            (orientedImage.size.width / imageSizeInView.width),
            (orientedImage.size.height / imageSizeInView.height)
        )
        let centerInOriginalImage = CGPoint(
            x: orientedImage.size.width / 2,
            y: orientedImage.size.height / 2
        )
        let cropSizeInOriginalImage = CGSize(
            width: (maskSize.width * factor) / scale,
            height: (maskSize.height * factor) / scale
        )
        
        let offsetX = offset.width * factor / scale
        let offsetY = offset.height * factor / scale
        
        let cropRectX = (centerInOriginalImage.x - cropSizeInOriginalImage.width / 2) - offsetX
        let cropRectY = (centerInOriginalImage.y - cropSizeInOriginalImage.height / 2) - offsetY
        
        return CGRect(
            origin: CGPoint(x: cropRectX, y: cropRectY),
            size: cropSizeInOriginalImage
        )
    }
}

private extension UIImage {
    
    var correctlyOriented: UIImage? {
        
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
}
