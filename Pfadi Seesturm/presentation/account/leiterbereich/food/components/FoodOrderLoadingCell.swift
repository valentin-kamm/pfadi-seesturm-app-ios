//
//  FoodOrderLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//

import SwiftUI

struct FoodOrderLoadingCell: View {
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("3\u{00D7}")
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .redacted(reason: .placeholder)
                .loadingBlinking()
            VStack(alignment: .trailing, spacing: 8) {
                Text("Pizza mit Salami")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .fontWeight(.bold)
                    .font(.callout)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
                Text("Sepp (3x), Peter (1x), Susi (5x)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .font(.caption)
                    .redacted(reason: .placeholder)
                    .loadingBlinking()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.skeletonPlaceholderColor)
                    .loadingBlinking()
                    .frame(width: 25, height: 25)
                .frame(width: 25)
            }
            .frame(width: 66, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    FoodOrderLoadingCell()
}
