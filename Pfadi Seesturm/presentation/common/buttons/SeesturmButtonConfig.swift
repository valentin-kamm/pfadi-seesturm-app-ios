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
    private let style: SeesturmButtonStyle
    
    init(
        type: SeesturmButtonType,
        buttonColor: Color,
        disabled: Bool,
        disabledAlpha: CGFloat,
        style: SeesturmButtonStyle
    ) {
        self.type = type
        self.buttonColor = buttonColor
        self.disabled = disabled
        self.disabledAlpha = disabledAlpha
        self.style = style
    }
    
    private var backgroundColor: Color {
        switch style {
        case .filled:
            buttonColor.opacity(disabled ? disabledAlpha : 1.0)
        case .outlined:
            .clear
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, type.verticalPadding)
            .padding(.horizontal, type.horizontalPadding)
            .buttonStyle(.plain)
            .overlay {
                if case .outlined = style {
                    Capsule()
                        .stroke(
                            buttonColor.opacity(disabled ? disabledAlpha : 1.0),
                            lineWidth: 4
                        )
                }
            }
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}
