//
//  PhotoGalleryCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI
import Kingfisher

struct PhotoGalleryCell: View {
    
    var width: CGFloat
    var height: CGFloat
    var thumbnailUrl: String
    var title: String?
    
    var body: some View {
        VStack(spacing: 8) {
            if let thumbnailUrl = URL(string: thumbnailUrl) {
                KFImage(thumbnailUrl)
                    .placeholder { progress in
                        Color.skeletonPlaceholderColor
                            .frame(width: width, height: height)
                            .cornerRadius(3)
                            .customLoadingBlinking()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .cornerRadius(3)
                    .clipped()
            }
            else {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(width: width, height: height)
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
                    .frame(width: width, alignment: .leading)
                    .fontWeight(.regular)
                    .lineLimit(1)
                    .allowsTightening(true)
            }
        }
        .padding(0)
    }
}

#Preview("Cell with Image and Text") {
    PhotoGalleryCell(
        width: 150,
        height: 150,
        thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG",
        title: "test"
    )
}
#Preview("Cell with Text and invalid image") {
    PhotoGalleryCell(
        width: 150,
        height: 150,
        thumbnailUrl: "1https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG",
        title: "long test text that overlaps"
    )
}
#Preview("Cell without text") {
    PhotoGalleryCell(
        width: 150,
        height: 150,
        thumbnailUrl: "https://seesturm.ch/wp-content/gallery/wofuba-17/IMG_9247.JPG"
    )
}
