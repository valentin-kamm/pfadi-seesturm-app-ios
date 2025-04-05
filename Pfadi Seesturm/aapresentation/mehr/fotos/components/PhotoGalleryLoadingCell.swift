//
//  PhotoGalleryLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotoGalleryLoadingCell: View {
    
    var size: CGFloat
    var withText: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.skeletonPlaceholderColor)
                .frame(width: size, height: size)
                .cornerRadius(3)
                .customLoadingBlinking()
            if withText {
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(width: size)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
            }
        }
        .padding(0)
    }
}

#Preview("With text") {
    PhotoGalleryLoadingCell(
        size: 150, withText: true
    )
}
#Preview("Without text") {
    PhotoGalleryLoadingCell(
        size: 150, withText: false
    )
}
