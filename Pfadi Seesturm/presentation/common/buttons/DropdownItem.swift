//
//  DropdownItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//

protocol DropdownItem: Identifiable {
    var title: String { get }
    var icon: DropdownItemIconType { get }
    var action: (() -> Void)? { get }
    var disabled: Bool { get }
}
