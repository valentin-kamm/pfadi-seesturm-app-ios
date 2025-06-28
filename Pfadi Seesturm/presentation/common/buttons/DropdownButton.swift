//
//  DropdownButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.02.2025.
//

import SwiftUI

struct DropdownButton<T: DropdownItem>: View {
    
    private let items: [T]
    private let onItemClick: ((T) -> Void)?
    private let title: String?
    private let icon: SeesturmButtonIconType
    private let colors: SeesturmButtonColor
    private let isLoading: Bool
    private let disabled: Bool
    
    init(
        items: [T],
        onItemClick: ((T) -> Void)? = nil,
        title: String?,
        icon: SeesturmButtonIconType = .system(name: "chevron.up.chevron.down"),
        colors: SeesturmButtonColor = .custom(contentColor: .SEESTURM_GREEN, buttonColor: .seesturmGray),
        isLoading: Bool = false,
        disabled: Bool = false
    ) {
        self.items = items
        self.onItemClick = onItemClick
        self.title = title
        self.icon = icon
        self.colors = colors
        self.isLoading = isLoading
        self.disabled = disabled
    }
    
    var body: some View {
        
        Menu {
            ForEach(items) { item in
                Button {
                    if let globalAction = onItemClick {
                        globalAction(item)
                    }
                    if let action = item.action {
                        action()
                    }
                } label: {
                    HStack {
                        Text(item.title)
                        switch item.icon {
                        case .checkmark(let isShown):
                            if isShown {
                                Image(systemName: "checkmark")
                            }
                        case .custom(let iconName):
                            Image(systemName: iconName)
                        default:
                            EmptyView()
                        }
                    }
                }
                .disabled(item.disabled)
            }
        } label: {
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: title,
                icon: icon,
                colors: colors,
                isLoading: isLoading,
                disabled: true,
                disabledAlpha: 1.0
            )
        }
        .disabled(disabled || isLoading)
    }
}

#Preview {
    VStack(alignment: .center, spacing: 16) {
        DropdownButton(
            items: [
                DropdownItemImpl(
                    title: "Test",
                    item: "Test",
                    icon: .custom(systemName: "house")
                )
            ],
            onItemClick: { item in },
            title: "Dropdown"
        )
        DropdownButton(
            items: [
                DropdownItemImpl(
                    title: "Test",
                    item: "Test",
                    icon: .custom(systemName: "house")
                )
            ],
            onItemClick: { item in },
            title: "Dropdown",
            isLoading: true
        )
        DropdownButton(
            items: [
                DropdownItemImpl(
                    title: "Test",
                    item: "Test",
                    icon: .custom(systemName: "house")
                )
            ],
            onItemClick: { item in },
            title: "Dropdown",
            disabled: true
        )
    }
}
