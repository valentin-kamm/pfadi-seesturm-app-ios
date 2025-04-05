//
//  EssenBestellungLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//

import SwiftUI

struct EssenBestellungLoadingCell: View {
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("3\u{00D7}")
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .redacted(reason: .placeholder)
                .customLoadingBlinking()
            VStack(alignment: .trailing, spacing: 8) {
                Text("Pizza mit Salami")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .fontWeight(.bold)
                    .font(.callout)
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
                Text("Sepp (3x), Peter (1x), Susi (5x)")
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .font(.caption)
                    .redacted(reason: .placeholder)
                    .customLoadingBlinking()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.skeletonPlaceholderColor)
                    .customLoadingBlinking()
                    .frame(width: 25, height: 25)
                .frame(width: 25)
            }
            .frame(width: 66, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EssenBestellungLoadingCell()
}
