//
//  LeiterbereichStufeCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct LeiterbereichStufeCardView<D: NavigationDestination>: View {
    
    let width: CGFloat
    let stufe: SeesturmStufe
    let onButtonClick: () -> Void
    let navigationDestination: D
    
    var body: some View {
        NavigationLink(value: navigationDestination) {
            CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
                ZStack(alignment: .trailing) {
                    VStack(alignment: .center, spacing: 8) {
                        stufe.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                        Text(stufe.stufenName)
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        SeesturmButton(
                            style: .tertiary,
                            action: .sync(action: {
                                onButtonClick()
                            }),
                            title: "Neue Aktivität",
                            icon: .system(name: "plus"),
                            colors: .custom(contentColor: .white, buttonColor: stufe.highContrastColor)
                        )
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .foregroundStyle(Color.primary)
        .frame(minWidth: width)
        .padding(.vertical)
    }
}

#Preview {
    LeiterbereichStufeCardView(
        width: 200,
        stufe: .pfadi,
        onButtonClick: {},
        navigationDestination: AccountNavigationDestination.anlaesse
    )
}
