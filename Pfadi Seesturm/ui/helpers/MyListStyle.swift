//
//  MyListStyle.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 12.11.2024.
//

import SwiftUI

struct MyListStyle: ViewModifier {
    let isListPlain: Bool
    func body(content: Content) -> some View {
        if isListPlain {
            content.listStyle(.plain)
        }
        else{
            content.listStyle(.insetGrouped)
        }
    }
}

extension View {
    func myListStyle(isListPlain: Bool) -> some View {
        modifier(MyListStyle(isListPlain: isListPlain))
    }
}
