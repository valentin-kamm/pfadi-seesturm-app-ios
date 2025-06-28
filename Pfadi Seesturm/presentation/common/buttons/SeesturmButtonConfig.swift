//
//  SeesturmButtonConfig.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.06.2025.
//
import SwiftUI

struct SeesturmButtonConfig: ButtonStyle {
    
    private let type: SeesturmButtonType
    private let buttonColor: Color
    private let disabled: Bool
    private let disabledAlpha: CGFloat
    
    init(
        type: SeesturmButtonType,
        buttonColor: Color,
        disabled: Bool,
        disabledAlpha: CGFloat
    ) {
        self.type = type
        self.buttonColor = buttonColor
        self.disabled = disabled
        self.disabledAlpha = disabledAlpha
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, type.verticalPadding)
            .padding(.horizontal, type.horizontalPadding)
            .buttonStyle(.plain)
            .background(buttonColor.opacity(disabled ? disabledAlpha : 1.0))
            .clipShape(Capsule())
    }
}
