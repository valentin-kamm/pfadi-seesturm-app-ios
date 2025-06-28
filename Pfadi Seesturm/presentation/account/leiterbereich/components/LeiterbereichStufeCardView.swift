//
//  LeiterbereichStufeCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct LeiterbereichStufeCardView<D: NavigationDestination>: View {
    
    private let width: CGFloat
    private let stufe: SeesturmStufe
    private let onButtonClick: () -> Void
    private let navigationDestination: D
    
    init(
        width: CGFloat,
        stufe: SeesturmStufe,
        onButtonClick: @escaping () -> Void,
        navigationDestination: D
    ) {
        self.width = width
        self.stufe = stufe
        self.onButtonClick = onButtonClick
        self.navigationDestination = navigationDestination
    }
    
    var body: some View {
        NavigationLink(value: navigationDestination) {
            CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
                ZStack(alignment: .trailing) {
                    VStack(alignment: .center, spacing: 8) {
                        stufe.icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                        Text(stufe.name)
                            .font(.callout)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        SeesturmButton(
                            type: .secondary,
                            action: .sync(action: onButtonClick),
                            title: "Neue Aktivität",
                            icon: .system(name: "plus"),
                            colors: .custom(contentColor: stufe.onHighContrastColor, buttonColor: stufe.highContrastColor)
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

#Preview("Light") {
    VStack(alignment: .center, spacing: 16) {
        ForEach(SeesturmStufe.allCases) { stufe in
            LeiterbereichStufeCardView(
                width: 120,
                stufe: stufe,
                onButtonClick: {},
                navigationDestination: AccountNavigationDestination.stufenbereich(stufe: stufe)
            )
        }
    }
    .padding()
    .preferredColorScheme(.light)
}
#Preview("Dark") {
    VStack(alignment: .center, spacing: 16) {
        ForEach(SeesturmStufe.allCases) { stufe in
            LeiterbereichStufeCardView(
                width: 120,
                stufe: stufe,
                onButtonClick: {},
                navigationDestination: AccountNavigationDestination.stufenbereich(stufe: stufe)
            )
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
