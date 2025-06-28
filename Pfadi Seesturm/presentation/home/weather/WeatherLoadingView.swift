//
//  WeatherLoadingView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI

struct WeatherLoadingView: View {
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Text(Constants.PLACEHOLDER_TEXT)
                    .lineLimit(1)
                    .fontWeight(.bold)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
                HStack(alignment: .center, spacing: 16) {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .loadingBlinking()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .loadingBlinking()
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                }
                CustomCardView(shadowColor: .clear, backgroundColor: .skeletonPlaceholderColor) {
                    Rectangle()
                        .fill(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                }
                .loadingBlinking()
            }
            .padding()
        }
        .padding()
    }
}

#Preview {
    WeatherLoadingView()
}
