//
//  LeitungsteamLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//

import SwiftUI

struct LeitungsteamLoadingCell: View {
    
    private let imageSize: CGFloat = 115
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Circle()
                .fill(Color.skeletonPlaceholderColor)
                .frame(width: imageSize, height: imageSize)
                .loadingBlinking()
            VStack(alignment: .leading, spacing: 16) {
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.bold)
                    .font(.title2)
                    .lineLimit(2)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
                Text(Constants.PLACEHOLDER_TEXT)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.caption)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    LeitungsteamLoadingCell()
}
