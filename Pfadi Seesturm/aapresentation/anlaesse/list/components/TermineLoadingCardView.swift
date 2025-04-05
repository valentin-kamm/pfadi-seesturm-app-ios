//
//  TermineLoadingCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.11.2024.
//

import SwiftUI

struct TermineLoadingCardView: View {
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            HStack(alignment: .center, spacing: 16) {
                CustomCardView(shadowColor: .clear, backgroundColor: .skeletonPlaceholderColor) {
                    VStack(alignment: .center, spacing: 8) {
                        
                    }
                    .frame(width: 100, height: 75)
                    .padding(8)
                }
                .customLoadingBlinking()
                VStack(alignment: .leading, spacing: 8) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .font(.subheadline)
                        .lineLimit(1)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    
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
    TermineLoadingCardView()
}
