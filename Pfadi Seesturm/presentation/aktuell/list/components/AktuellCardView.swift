//
//  AktuellCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI
import Kingfisher
import RichText

struct AktuellCardView: View {
    
    private let post: WordpressPost
    private let width: CGFloat
    
    private let cardAspectRatio = 1.0
    private let cardWidth: CGFloat
    private let cardHeight: CGFloat
    
    init(
        post: WordpressPost,
        width: CGFloat
    ) {
        self.post = post
        self.width = width
        self.cardWidth = width - 32
        self.cardHeight = cardWidth / cardAspectRatio
    }
    
    var body: some View {
        
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            ZStack(alignment: .bottom) {
                if let imageUrl = URL(string: post.imageUrl) {
                    KFImage(imageUrl)
                        .placeholder { progress in
                            Rectangle()
                                .fill(Color.skeletonPlaceholderColor)
                                .aspectRatio(cardAspectRatio, contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .loadingBlinking()
                        }
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(0.9, contentMode: .fill)
                        .frame(width: cardWidth, height: cardHeight)
                        .clipped()
                }
                else {
                    Color.skeletonPlaceholderColor
                        .frame(width: cardWidth, height: cardHeight)
                        .overlay {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                                .padding(.bottom, 165)
                        }
                }
                VStack(alignment: .leading) {
                    Text(post.titleDecoded)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                    Label(post.publishedFormatted.uppercased(), systemImage: "calendar")
                        .lineLimit(1)
                        .font(.caption2)
                        .foregroundStyle(Color.secondary)
                        .labelStyle(.titleAndIcon)
                        .padding(.bottom, 8)
                    Text(post.contentPlain)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding([.horizontal, .bottom])
    }
}

#Preview("Ohne Bild") {
    GeometryReader { geometry in
        AktuellCardView(
            post: DummyData.aktuellPost3,
            width: geometry.size.width
        )
    }
}
#Preview("Hochformat") {
    GeometryReader { geometry in
        AktuellCardView(
            post: DummyData.aktuellPost2,
            width: geometry.size.width
        )
    }
}
#Preview("Normal") {
    GeometryReader { geometry in
        AktuellCardView(
            post: DummyData.aktuellPost1,
            width: geometry.size.width
        )
    }
}
