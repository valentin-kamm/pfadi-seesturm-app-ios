//
//  PhotoGalleryLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct PhotoGalleryLoadingCell: View {
    
    private let size: CGFloat
    private let withText: Bool
    
    init(
        size: CGFloat,
        withText: Bool
    ) {
        self.size = size
        self.withText = withText
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Rectangle()
                .fill(Color.skeletonPlaceholderColor)
                .frame(width: size, height: size)
                .cornerRadius(3)
                .loadingBlinking()
            if withText {
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(width: size)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
            }
        }
    }
}

#Preview {
    VStack {
        PhotoGalleryLoadingCell(
            size: 150, withText: true
        )
        PhotoGalleryLoadingCell(
            size: 150, withText: false
        )
    }
}
