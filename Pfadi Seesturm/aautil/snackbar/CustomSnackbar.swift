//
//  CustomSnackbar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct CustomSnackbarModifier: ViewModifier {
    
    @Binding var show: Bool
    let type: SnackbarType
    let message: String
    let config: SnackbarConfig
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            SnackbarView(
                show: $show,
                type: type,
                message: message,
                config: config,
                onDismiss: onDismiss
            )
        }
    }
}

extension View {
    func customSnackbar(
        show: Binding<Bool>,
        type: SnackbarType,
        message: String,
        dismissAutomatically: Bool,
        allowManualDismiss: Bool,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            CustomSnackbarModifier(
                show: show,
                type: type,
                message: message,
                config: SnackbarConfig(
                    dismissAutomatically: dismissAutomatically,
                    allowManualDismiss: allowManualDismiss
                ),
                onDismiss: onDismiss
            )
        )
    }
}
