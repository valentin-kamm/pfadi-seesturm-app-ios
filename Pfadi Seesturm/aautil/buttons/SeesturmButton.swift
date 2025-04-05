//
//  CustomPrimaryButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct SeesturmButton: View {
    
    private let style: SeesturmButtonStyle
    private let action: SeesturmButtonAction
    private let title: String?
    private let icon: SeesturmButtonIconType
    private let colors: SeesturmButtonColor
    private let isLoading: Bool
    private let isDisabled: Bool
    
    init(
        style: SeesturmButtonStyle,
        action: SeesturmButtonAction,
        title: String?,
        icon: SeesturmButtonIconType = .none,
        colors: SeesturmButtonColor = .predefined,
        isLoading: Bool = false,
        isDisabled: Bool = false
    ) {
        self.style = style
        self.title = title
        self.icon = icon
        self.colors = colors
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    private var contentColor: Color {
        if isLoading {
            return Color.clear
        }
        switch colors {
        case .predefined:
            return style.predefinedContentColor
        case .custom(let contentColor, _):
            return contentColor
        }
    }
    private var progressIndicatorColor: Color {
        switch colors {
        case .predefined:
            return style.predefinedContentColor
        case .custom(let contentColor, _):
            return contentColor
        }
    }
    private var buttonColor: Color {
        switch colors {
        case .predefined:
            return style.predefinedButtonColor
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
                }
            }
        }
        .buttonStyle(
            SeesturmButtonConfig(
                style: style,
                buttonColor: buttonColor
            )
        )
        .disabled(isLoading || isDisabled)
    }
}

enum SeesturmButtonStyle {
    case primary
    case secondary
    case tertiary
    
    var predefinedButtonColor: Color {
        switch self {
        case .primary:
            return .SEESTURM_RED
        case .secondary:
            return .seesturmGray
        case .tertiary:
            return .SEESTURM_GREEN
        }
    }
    var predefinedContentColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .SEESTURM_GREEN
        case .tertiary:
            return .white
        }
    }
    var horizontalPadding: CGFloat {
        switch self {
        case .primary, .secondary:
            16
        case .tertiary:
            12
        }
    }
    var verticalPadding: CGFloat {
        switch self {
        case .primary, .secondary:
            12
        case .tertiary:
            8
        }
    }
}

struct SeesturmButtonConfig: ButtonStyle {
    
    private let style: SeesturmButtonStyle
    private let buttonColor: Color
    init(
        style: SeesturmButtonStyle,
        buttonColor: Color
    ) {
        self.style = style
        self.buttonColor = buttonColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, style.verticalPadding)
            .padding(.horizontal, style.horizontalPadding)
            .buttonStyle(.plain)
            .background(buttonColor)
            .clipShape(Capsule())
    }
}

enum SeesturmButtonIconType {
    case none
    case system(name: String)
    case custom(name: String, width: CGFloat, height: CGFloat)
}
enum SeesturmButtonColor {
    case predefined
    case custom(contentColor: Color, buttonColor: Color)
}
enum SeesturmButtonAction {
    case none
    case sync(action: () -> Void)
    case async(action: () async -> Void)
}

#Preview {
    let buttonText = "Test"
    let buttonIcon = SeesturmButtonIconType.system(name: "house")
    HStack {
        VStack {
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: .none,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .custom(contentColor: .black, buttonColor: .cyan),
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: true,
                isDisabled: false
            )
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: true
            )
            SeesturmButton(
                style: .primary,
                action: .none,
                title: buttonText,
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
        }
        VStack {
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: .none,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .custom(contentColor: .black, buttonColor: .cyan),
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: true,
                isDisabled: false
            )
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: true
            )
            SeesturmButton(
                style: .secondary,
                action: .none,
                title: buttonText,
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
        }
        VStack {
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: .none,
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .custom(contentColor: .black, buttonColor: .cyan),
                isLoading: false,
                isDisabled: false
            )
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: true,
                isDisabled: false
            )
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: buttonIcon,
                colors: .predefined,
                isLoading: false,
                isDisabled: true
            )
            SeesturmButton(
                style: .tertiary,
                action: .none,
                title: buttonText,
                icon: .custom(name: "midataLogo", width: 30, height: 30),
                colors: .predefined,
                isLoading: false,
                isDisabled: false
            )
        }
    }
}











/*
extension View {
    @ViewBuilder
    func applySeesturmButtonStyle(style: SeesturmButtonStyle) -> some View {
        switch style {
        case .primary:
            self.buttonStyle(.borderedProminent)
        case .secondary:
            self.buttonStyle(.bordered)
        case .tertiary:
            self.buttonStyle(.borderedProminent)
        }
    }
}
 /*
  
  
 .applySeesturmButtonStyle(style: style)
 //
 
 .foregroundStyle(Color.SEESTURM_YELLOW)
 
 
 //.tint(buttonColor)
 
  */
 */





/*
// custom primary button that is used throughout the app
struct CustomButton: View {
    
    
    
    
    
    var body: some View {
        
        VStack {
            switch buttonStyle {
            case .icon(let backgroundColor, let contentColor):
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        if let systemIconName = buttonSystemIconName {
                            Image(systemName: systemIconName)
                                .padding(2)
                        }
                        else if let customIconName = buttonCustomIconName {
                            Image(customIconName)
                                .renderingMode(isLoading ? Image.TemplateRenderingMode.template : Image.TemplateRenderingMode.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(2)
                        }
                        if isLoading {
                            ProgressView()
                                .tint(contentColor)
                        }
                    }
                }
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .buttonStyle(.plain)
                .disabled(isLoading || isDisabled)
                .clipShape(Circle())
                .foregroundStyle(isLoading ? Color.clear : contentColor)
            case .primary(let buttonColor):
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        if isLoading {
                            ProgressView()
                                .tint(Color.white)
                        }
                    }
                }
                .buttonStyle(PrimaryButtonConfig(isLoading: isLoading, buttonColor: buttonColor))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading || isDisabled)
            case .secondary:
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        if isLoading {
                            ProgressView()
                        }
                    }
                }
                .buttonStyle(SecondaryButtonConfig(isLoading: isLoading))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading || isDisabled)
            case .tertiary(let color):
                Button {
                    if let buttonAction = buttonAction {
                        buttonAction()
                    }
                    else if let asyncButtonAction = asyncButtonAction {
                        Task {
                            try? await asyncButtonAction()
                        }
                    }
                } label: {
                    ZStack {
                        HStack {
                            if let title = buttonTitle {
                                Text(title)
                                    .lineLimit(1)
                            }
                            if let systemIconName = buttonSystemIconName {
                                Image(systemName: systemIconName)
                            }
                            else if let customIconName = buttonCustomIconName {
                                Image(customIconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        if isLoading {
                            ProgressView()
                                .tint(Color.white)
                        }
                    }
                }
                .buttonStyle(TertiaryButtonConfig(isLoading: isLoading, buttonColor: color))
                .cornerRadius(16)
                .buttonStyle(.plain)
                .disabled(isLoading || isDisabled)
            }
        }
    }
}

struct SeesturmPrimaryButtonStyle: ButtonStyle {
    
    let isLoading: Bool
    let buttonColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(buttonColor)
            .foregroundStyle(isLoading ? Color.clear : Color.white)
    }
}
struct SeesturmSecondaryButtonStyle: ButtonStyle {
    
    let isLoading: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
            .foregroundStyle(isLoading ? Color.clear : Color.primary)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.SEESTURM_GREEN, lineWidth: 5)
            }
    }
}
struct SeesturmTertiaryButtonConfig: ButtonStyle {
    var isLoading: Bool
    var buttonColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .clipShape(Capsule())
            .background(buttonColor)
            .foregroundStyle(isLoading ? Color.clear : Color.white)
            .font(.subheadline)
    }
}

/*
#Preview("Icon Button") {
    CustomButton(
        buttonStyle: .icon(
            backgroundColor: .green,
            contentColor: .SEESTURM_GREEN
        ),
        buttonTitle: nil,
        buttonCustomIconName: "SeesturmLogo",
        isLoading: false
    )
}
#Preview("Primary Button") {
    CustomButton(
        buttonStyle: .primary(color: Color.SEESTURM_RED),
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: false
    )
}
#Preview("Primary Button Loading") {
    CustomButton(
        buttonStyle: .primary(color: Color.SEESTURM_RED),
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: true
    )
}

#Preview("Secondary Button") {
    CustomButton(
        buttonStyle: .secondary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: false
    )
}
#Preview("Secondary Button Loading") {
    CustomButton(
        buttonStyle: .secondary,
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: true
    )
}

#Preview("Tertiary Button") {
    CustomButton(
        buttonStyle: .tertiary(),
        buttonTitle: "Test-Button",
        buttonCustomIconName: "midataLogo",
        isLoading: false
    )
}
#Preview("Tertiary Button Loading") {
    CustomButton(
        buttonStyle: .tertiary(),
        buttonTitle: "Test-Button",
        buttonSystemIconName: "house",
        isLoading: true
    )
}
*/
*/
