//
//  ImageFitSize.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.08.2025.
//

import SwiftUI

// calculates size for an fitting image inside of a view
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
            // image is taller or equal to the view
            let height = self.height
            let width = height * imageAspectRatio
            imageSize = CGSize(width: width, height: height)
        }
        return imageSize
    }
}
