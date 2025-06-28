//
//  DocumentLoadingCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI

struct DocumentLoadingCardView: View {
    
    private let thumbnailWidth: CGFloat = 75
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 16) {
            Rectangle()
                .fill(Color.skeletonPlaceholderColor)
                .frame(width: thumbnailWidth, height: thumbnailWidth / (212/300))
                .loadingBlinking()
            VStack(alignment: .leading, spacing: 16) {
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.bold)
                    .font(.title2)
                    .allowsTightening(true)
                    .lineLimit(2)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
                Text("Donnerstag, 25. Juli 2024")
                    .lineLimit(1)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .allowsTightening(true)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
            }
        }
        .padding()
    }
}

#Preview {
    DocumentLoadingCardView()
}
