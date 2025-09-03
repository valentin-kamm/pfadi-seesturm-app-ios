//
//  ImageAspectRatio.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.08.2025.
//

import UIKit

extension UIImage {
    var aspectRatio: CGFloat {
        return self.size.width / self.size.height
    }
}
