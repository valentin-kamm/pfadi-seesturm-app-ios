//
//  DocumentCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI
import Kingfisher

struct DocumentCardView: View {
    
    private let document: WordpressDocument
    private let thumbnailWidth: CGFloat = 75
    
    init(
        document: WordpressDocument
    ) {
        self.document = document
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            if let imageUrl = URL(string: document.thumbnailUrl) {
                KFImage(imageUrl)
                    .placeholder { progress in
                        Color.skeletonPlaceholderColor
                            .frame(width: thumbnailWidth, height: thumbnailWidth / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                            .loadingBlinking()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: thumbnailWidth, height: thumbnailWidth / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                    .clipped()
            }
            else {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(width: thumbnailWidth, height: thumbnailWidth / (Double(document.thumbnailWidth) / Double(document.thumbnailHeight)))
                    .overlay {
                        Image(systemName: "doc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
            }
            VStack(alignment: .leading, spacing: 16) {
                Text(document.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.bold)
                    .font(.title2)
                    .allowsTightening(true)
                    .lineLimit(2)
                Label(document.publishedFormatted.uppercased(), systemImage: "calendar")
                    .lineLimit(2)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsTightening(true)
            }
        }
        .padding()
    }
}

#Preview {
    VStack {
        DocumentCardView(document: DummyData.document1)
        DocumentCardView(document: DummyData.document2)
    }
}
