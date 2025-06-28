//
//  AktuellLoadingCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct AktuellLoadingCardView: View {
    
    var body: some View {
        
        CustomCardView {
            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .loadingBlinking()
                Text(Constants.PLACEHOLDER_TEXT)
                    .padding()
                    .redacted(reason: .placeholder)
                    .lineLimit(3)
                    .loadingBlinking()
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.horizontal, .bottom])
    }
    
}

#Preview {
    AktuellLoadingCardView()
}
