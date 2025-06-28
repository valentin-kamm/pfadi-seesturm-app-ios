//
//  LeitungsteamLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//

import SwiftUI

struct LeitungsteamLoadingCell: View {
    
    private let imageSize: CGFloat = 130
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            HStack(spacing: 16) {
                Color.skeletonPlaceholderColor
                    .frame(width: imageSize, height: imageSize)
                    .loadingBlinking()
                VStack(alignment: .leading, spacing: 8) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .font(.callout)
                        .lineLimit(2)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .font(.caption)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Spacer(minLength: 0)
                }
                .padding([.vertical, .trailing])
                .frame(maxWidth: .infinity, maxHeight: imageSize, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LeitungsteamLoadingCell()
}
