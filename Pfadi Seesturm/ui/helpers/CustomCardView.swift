//
//  CustomCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

// custom card view that is used throughout the entire app
struct CustomCardView<Content: View>: View {
    
    let shadowColor: Color
    let backgroundColor: Color
    let content: Content
    
    init(
        shadowColor: Color = .seesturmGreenCardViewShadowColor,
        backgroundColor: Color = .customCardViewBackground,
        @ViewBuilder content: () -> Content
    ) {
        self.shadowColor = shadowColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(16)
            .shadow(color: shadowColor.opacity(0.3), radius: 5, x: 0, y: 0)
    }
}

#Preview {
    CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
        Text(Constants.PLACEHOLDER_TEXT)
            .padding()
    }
    .padding()
}
