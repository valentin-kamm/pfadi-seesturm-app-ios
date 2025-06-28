//
//  FocusControlItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.06.2025.
//

protocol FocusControlItem: Hashable, CaseIterable, Identifiable {
    var id: Self { get }
}
