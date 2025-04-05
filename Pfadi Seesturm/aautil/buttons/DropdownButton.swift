//
//  DropdownButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.02.2025.
//

import SwiftUI

struct DropdownButton<T: DropdownItem>: View {
    
    let items: [T]
    let onItemClick: ((T) -> Void)?
    private let title: String?
    private let icon: SeesturmButtonIconType
    private let colors: SeesturmButtonColor
    private let isLoading: Bool
    private let isDisabled: Bool
    
    init(
        items: [T],
        onItemClick: ((T) -> Void)? = nil,
        title: String?,
        icon: SeesturmButtonIconType = .system(name: "chevron.up.chevron.down"),
        colors: SeesturmButtonColor = .custom(contentColor: .SEESTURM_GREEN, buttonColor: .seesturmGray),
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.items = items
        self.onItemClick = onItemClick
        self.title = title
        self.icon = icon
        self.colors = colors
        self.isLoading = isLoading
        self.isDisabled = isDisabled
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
                style: .tertiary,
                action: .none,
                title: title,
                icon: icon,
                colors: colors,
                isLoading: isLoading,
                isDisabled: true
            )
        }
        .disabled(isDisabled)
    }
}

protocol DropdownItem: Identifiable {
    var title: String { get }
    var icon: DropdownItemIconType { get }
    var action: (() -> Void)? { get }
    var disabled: Bool { get }
}
struct DropdownItemImpl<T>: DropdownItem {
    let id: UUID
    let title: String
    let item: T
    let icon: DropdownItemIconType
    let action: (() -> Void)?
    let disabled: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        item: T,
        icon: DropdownItemIconType = .none,
        action: (() -> Void)? = nil,
        disabled: Bool = false
    ) {
        self.id = id
        self.title = title
        self.item = item
        self.icon = icon
        self.action = action
        self.disabled = disabled
    }
}
enum DropdownItemIconType {
    case checkmark(isShown: Bool)
    case custom(systemName: String)
    case none
}

#Preview {
    DropdownButton(
        items: [
            DropdownItemImpl(
                title: "Test",
                item: "Test",
                icon: .custom(systemName: "house")
            )
        ],
        onItemClick: { item in },
        title: "Test",
        isLoading: false,
        isDisabled: false
    )
}
