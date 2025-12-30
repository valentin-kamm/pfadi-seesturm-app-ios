//
//  ImageUtils.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

import UIKit

extension UIImage {
    
    var aspectRatio: CGFloat {
        return self.size.width / self.size.height
    }
    
    func shrink(to largestSide: CGFloat) -> UIImage {
        
        if self.size.width <= largestSide && self.size.height <= largestSide {
            return self
        }
        
        let aspectRatio = self.aspectRatio
        
        let targetSize: CGSize
        if aspectRatio > 1 {
            targetSize = CGSize(width: largestSide, height: largestSide / aspectRatio)
        }
        else {
            targetSize = CGSize(width: largestSide * aspectRatio, height: largestSide)
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        
        return renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

extension CGSize {
    
    func imageFitSize(for imageAspectRatio: CGFloat) -> CGSize {
        
        let viewAspectRatio = self.width / self.height
        
        let imageSize: CGSize
        if imageAspectRatio > viewAspectRatio {
            // image is wider than the view
            let width = self.width
            let height = width / imageAspectRatio
            imageSize = CGSize(width: width, height: height)
        }
        else {
            // image is taller than the view
            let height = self.height
            let width = height * imageAspectRatio
            imageSize = CGSize(width: width, height: height)
        }
        return imageSize
    }
}
