//
//  PhotoGalleryCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI
import Kingfisher

struct PhotoGalleryCell: View {
    
    private let size: CGFloat
    private let thumbnailUrl: String
    private let title: String?
    
    init(
        size: CGFloat,
        thumbnailUrl: String,
        title: String? = nil
    ) {
        self.size = size
        self.thumbnailUrl = thumbnailUrl
        self.title = title
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let thumbnailUrl = URL(string: thumbnailUrl) {
                KFImage(thumbnailUrl)
                    .placeholder { progress in
                        Color.skeletonPlaceholderColor
                            .frame(width: size, height: size)
                            .cornerRadius(3)
                            .loadingBlinking()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .cornerRadius(3)
                    .clipped()
            }
            else {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(width: size, height: size)
                    .cornerRadius(3)
                    .overlay {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
            }
            if let title = title {
                Text(title)
                    .frame(width: size, alignment: .leading)
                    .fontWeight(.regular)
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        }
        .padding(0)
    }
}

#Preview {
    VStack {
        PhotoGalleryCell(
            size: 150,
            thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG",
            title: "test"
        )
        PhotoGalleryCell(
            size: 150,
            thumbnailUrl: "",
            title: "long test text that overlaps"
        )
        PhotoGalleryCell(
            size: 150,
            thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
        )
    }
}
