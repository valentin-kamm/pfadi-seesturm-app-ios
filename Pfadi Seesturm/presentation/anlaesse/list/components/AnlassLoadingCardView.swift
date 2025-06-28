//
//  AnlassLoadingCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.11.2024.
//

import SwiftUI

struct AnlassLoadingCardView: View {
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            HStack(alignment: .center, spacing: 16) {
                CustomCardView(shadowColor: .clear) {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(width: 116, height: 91)
                        .loadingBlinking()
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .font(.subheadline)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                }
                .layoutPriority(1)
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    AnlassLoadingCardView()
}
