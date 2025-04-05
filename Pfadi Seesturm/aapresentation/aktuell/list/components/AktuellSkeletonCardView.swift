//
//  AktuellSkeletonCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct AktuellSkeletonCardView: View {
    var body: some View {
        let width = UIScreen.main.bounds.width - 32
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            VStack (alignment: .leading) {
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(width: width, height: 250)
                    .customLoadingBlinking()
                Text(Constants.PLACEHOLDER_TEXT)
                    .padding()
                    .redacted(reason: .placeholder)
                    .lineLimit(3)
                    .customLoadingBlinking()
            }
        }
        .padding([.horizontal, .bottom])
        .background(Color.clear)
    }
}

#Preview {
    AktuellSkeletonCardView()
}
