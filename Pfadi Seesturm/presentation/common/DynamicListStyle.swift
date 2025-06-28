//
//  DynamicListStyle.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 12.11.2024.
//

import SwiftUI

struct DynamicListStyle: ViewModifier {
    
    private let isListPlain: Bool
    
    init(isListPlain: Bool) {
        self.isListPlain = isListPlain
    }
    
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
    func dynamicListStyle(isListPlain: Bool) -> some View {
        modifier(DynamicListStyle(isListPlain: isListPlain))
    }
}
