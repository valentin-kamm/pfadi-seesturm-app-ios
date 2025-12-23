//
//  ImageFitSize.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//

import SwiftUI

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
