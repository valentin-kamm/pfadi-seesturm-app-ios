//
//  CustomSnackbar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct CustomSnackbarModifier: ViewModifier {
    
    private var show: Binding<Bool>
    private let type: SeesturmSnackbarType
    private let message: String
    private let dismissAutomatically: Bool
    private let allowManualDismiss: Bool
    private let onDismiss: (() -> Void)?
    
    init(
        show: Binding<Bool>,
        type: SeesturmSnackbarType,
        message: String,
        dismissAutomatically: Bool,
        allowManualDismiss: Bool,
        onDismiss: (() -> Void)?
    ) {
        self.show = show
        self.type = type
        self.message = message
        self.dismissAutomatically = dismissAutomatically
        self.allowManualDismiss = allowManualDismiss
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            SnackbarView(
                show: show,
                type: type,
                message: message,
                dismissAutomatically: dismissAutomatically,
                allowManualDismiss: allowManualDismiss,
                onDismiss: onDismiss
            )
        }
    }
}

extension View {
    func customSnackbar(
        show: Binding<Bool>,
        type: SeesturmSnackbarType,
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
                dismissAutomatically: dismissAutomatically,
                allowManualDismiss: allowManualDismiss,
                onDismiss: onDismiss
            )
        )
    }
}
