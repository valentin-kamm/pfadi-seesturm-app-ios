//
//  ListSectionHeader.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

struct MainSectionHeader: View {
    
    private let headerType: ListSectionHeaderType
    private let sectionTitle: String
    private let iconName: String
    
    init(
        headerType: ListSectionHeaderType,
        sectionTitle: String,
        iconName: String
    ) {
        self.headerType = headerType
        self.sectionTitle = sectionTitle
        self.iconName = iconName
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .foregroundStyle(Color.SEESTURM_RED)
            Text(sectionTitle)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2)
                .fontWeight(.bold)
                .layoutPriority(1)
                .lineLimit(2)
            if case .button(let buttonTitle, let icon, let action) = headerType {
                SeesturmButton(
                    type: .secondary,
                    action: action,
                    title: buttonTitle,
                    icon: icon
                )
                .layoutPriority(1)
            }
            else if case .stufenButton(let selectedStufen, let onClick) = headerType {
                DropdownButton(
                    items: SeesturmStufe.allCases.sorted(by: { $0.id < $1.id }).map {
                        DropdownItemImpl(
                            title: $0.name,
                            item: $0,
                            icon: .checkmark(isShown: selectedStufen.contains($0))
                        )
                    },
                    onItemClick: { item in
                        onClick(item.item)
                    },
                    title: selectedStufen.stufenDropdownText
                )
                .layoutPriority(1)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("Ohne Button") {
    MainSectionHeader(
        headerType: .blank,
        sectionTitle: "Nächste Aktivität",
        iconName: "person.2.circle.fill"
    )
}

#Preview("Mit Button") {
    MainSectionHeader(
        headerType: .button(
            buttonTitle: "Mehr",
            icon: .system(name: "chevron.right"),
            action: .none
        ),
        sectionTitle: "Nächste Aktivität",
        iconName: "person.2.circle.fill"
    )
}

#Preview("Stufen Button") {
    MainSectionHeader(
        headerType: .stufenButton(selectedStufen: [.biber, .wolf], onClick: { _ in }),
        sectionTitle: "Stufen",
        iconName: "person.2.circle.fill"
    )
}
