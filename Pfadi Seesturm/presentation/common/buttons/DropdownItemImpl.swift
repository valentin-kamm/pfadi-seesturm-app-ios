//
//  DropdownItemImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//
import Foundation

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
