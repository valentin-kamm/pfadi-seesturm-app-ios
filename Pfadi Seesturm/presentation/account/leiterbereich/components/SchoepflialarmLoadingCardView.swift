//
//  SchoepflialarmLoadingCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.04.2025.
//

import SwiftUI

struct SchoepflialarmLoadingCardView: View {
    
    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    Circle()
                        .fill(Color.skeletonPlaceholderColor)
                        .loadingBlinking()
                        .frame(width: 30, height: 30)
                    Text("Vorname Nachname Pfadiname")
                        .font(.callout)
                        .lineLimit(1)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text(Constants.PLACEHOLDER_TEXT)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
                
                HStack(alignment: .center, spacing: 8) {
                    ForEach(SchoepflialarmReactionType.allCases) { _ in
                        CustomCardView(shadowColor: .clear, backgroundColor: .skeletonPlaceholderColor) {
                            Rectangle()
                                .fill(.clear)
                                .frame(height: 35)
                        }
                        .loadingBlinking()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
}

#Preview {
    SchoepflialarmLoadingCardView()
        .padding()
}
