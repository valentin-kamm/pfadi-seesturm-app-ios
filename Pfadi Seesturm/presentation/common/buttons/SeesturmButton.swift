//
//  SeesturmButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct SeesturmButton: View {
    
    private let type: SeesturmButtonType
    private let action: SeesturmButtonAction
    private let title: String?
    private let icon: SeesturmButtonIconType
    private let colors: SeesturmButtonColor
    private let isLoading: Bool
    private let disabled: Bool
    private let maxWidth: CGFloat?
    private let disabledAlpha: CGFloat
    
    init(
        type: SeesturmButtonType,
        action: SeesturmButtonAction,
        title: String?,
        icon: SeesturmButtonIconType = .none,
        colors: SeesturmButtonColor = .predefined,
        isLoading: Bool = false,
        disabled: Bool = false,
        maxWidth: CGFloat? = nil,
        disabledAlpha: CGFloat = 0.6
    ) {
        self.type = type
        self.title = title
        self.icon = icon
        self.colors = colors
        self.isLoading = isLoading
        self.disabled = disabled
        self.action = action
        self.maxWidth = maxWidth
        self.disabledAlpha = disabledAlpha
    }
    
    private var contentColor: Color {
        if isLoading {
            return Color.clear
        }
        switch colors {
        case .predefined:
            return type.predefinedContentColor
        case .custom(let contentColor, _):
            return contentColor
        }
    }
    private var progressIndicatorColor: Color {
        switch colors {
        case .predefined:
            return type.predefinedContentColor
        case .custom(let contentColor, _):
            return contentColor
        }
    }
    private var buttonColor: Color {
        switch colors {
        case .predefined:
            return type.predefinedButtonColor
        case .custom(_, let buttonColor):
            return buttonColor
        }
    }
    
    var body: some View {
        Button {
            switch action {
            case .none:
                break
            case .sync(let action):
                action()
            case .async(let action):
                Task {
                    await action()
                }
            }
        } label: {
            ZStack {
                HStack {
                    if let buttonTitle = title {
                        Text(buttonTitle)
                            .lineLimit(1)
                            .foregroundStyle(contentColor)
                            .fontWidth(.condensed)
                    }
                    switch icon {
                    case .none:
                        EmptyView()
                    case .system(let name):
                        Image(systemName: name)
                            .foregroundStyle(contentColor)
                    case .custom(let name, let width, let height):
                        Image(name)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                            .foregroundStyle(contentColor)
                    }
                }
                if isLoading {
                    ProgressView()
                        .tint(progressIndicatorColor)
                        .id(UUID())
                }
            }
            .frame(maxWidth: maxWidth)
        }
        .buttonStyle(
            SeesturmButtonConfig(
                type: type,
                buttonColor: buttonColor,
                disabled: isLoading || disabled,
                disabledAlpha: disabledAlpha
            )
        )
        .disabled(isLoading || disabled)
    }
}

#Preview {
    HStack(alignment: .top, spacing: 16) {
        VStack(alignment: .center, spacing: 16) {
            // simple
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED)
            )
            // simple with icon
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED)
            )
            // nur icon
            SeesturmButton(
                type: .primary,
                action: .none,
                title: nil,
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED)
            )
            // simple loading
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED),
                isLoading: true
            )
            // simple with icon loading
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED),
                isLoading: true
            )
            // simple disabled
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED),
                disabled: true
            )
            // icon disabled
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED),
                disabled: true
            )
            // custom icon
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED)
            )
            // custom icon disabled
            SeesturmButton(
                type: .primary,
                action: .none,
                title: "Primary",
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_RED),
                disabled: true
            )
        }
        VStack(alignment: .center, spacing: 16) {
            // simple
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN)
            )
            // simple with icon
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN)
            )
            // nur icon
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: nil,
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN)
            )
            // simple loading
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN),
                isLoading: true
            )
            // simple with icon loading
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN),
                isLoading: true
            )
            // simple disabled
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN),
                disabled: true
            )
            // icon disabled
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                icon: .system(name: "house"),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN),
                disabled: true
            )
            // custom icon
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN)
            )
            // custom icon disabled
            SeesturmButton(
                type: .secondary,
                action: .none,
                title: "Secondary",
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .custom(contentColor: .black, buttonColor: .SEESTURM_GREEN),
                disabled: true
            )
        }
    }
    .padding(16)
}
