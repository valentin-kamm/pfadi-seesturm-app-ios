//
//  AktivitaetHomeLoadingView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//

import SwiftUI

struct AktivitaetHomeLoadingView: View {
    
    private let width: CGFloat
    init(
        width: CGFloat
    ) {
        self.width = width
    }

    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Circle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(width: 40, height: 40)
                        .loadingBlinking()
                }
                Text(Constants.PLACEHOLDER_TEXT)
                    .foregroundStyle(Color.secondary)
                    .font(.subheadline)
                    .lineLimit(2)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
            }
            .padding()
            
        }
        .frame(width: width)
        .padding(.vertical)
    }
}

#Preview {
    GeometryReader { geometry in
        AktivitaetHomeLoadingView(
            width: geometry.size.width - 32
        )
        .padding(.horizontal)
    }
}
