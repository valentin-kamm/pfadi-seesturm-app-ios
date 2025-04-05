//
//  ErrorSnackbar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct ActionSnackbarModifier<D>: ViewModifier {
    
    @Binding private var action: ActionState<D>
    private let binaryTypes: [BinarySnackbarType]
    private let defaultErrorMessage: String
    private let defaultSuccessMessage: String
    private let actionResetState: ActionState<D>
    
    private let types: [SnackbarType]
    
    init(
        action: Binding<ActionState<D>>,
        events: [BinarySnackbarType],
        defaultErrorMessage: String,
        defaultSuccessMessage: String,
        actionResetState: ActionState<D>
    ) {
        self._action = action
        self.binaryTypes = events
        self.defaultErrorMessage = defaultErrorMessage
        self.defaultSuccessMessage = defaultSuccessMessage
        self.actionResetState = actionResetState
        
        self.types = events.map { SnackbarType(from: $0) }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            snackbarView
        }
    }
    
    @ViewBuilder
    private var snackbarView: some View {
        if types.contains(.error) {
            SnackbarView(
                show: showError,
                type: .error,
                message: errorMessage,
                config: SnackbarConfig(
                    dismissAutomatically: dismissErrorAutomatically,
                    allowManualDismiss: allowErrorManualDismiss
                ),
                onDismiss: { self.action = actionResetState }
            )
        }
        if types.contains(.success) {
            SnackbarView(
                show: showSuccess,
                type: .success,
                message: successMessage,
                config: SnackbarConfig(
                    dismissAutomatically: dismissSuccessAutomatically,
                    allowManualDismiss: allowSuccessManualDismiss
                ),
                onDismiss: { self.action = actionResetState }
            )
        }
    }
    
    private var showError: Binding<Bool> {
        Binding(
            get: {
                if types.contains(.error) {
                    switch action {
                    case .error(_, _):
                        return true
                    default:
                        return false
                    }
                }
                return false
            },
            set: { isShown in
                if !isShown { self.action = actionResetState }
            }
        )
    }
    private var showSuccess: Binding<Bool> {
        Binding(
            get: {
                if types.contains(.success) {
                    switch action {
                    case .success(_, _):
                        return true
                    default:
                        return false
                    }
                }
                return false
            },
            set: { isShown in
                if !isShown { self.action = actionResetState }
            }
        )
    }
    
    private var errorMessage: String {
        if case .error(_, let message) = action {
            return message
        }
        return defaultErrorMessage
    }
    private var successMessage: String {
        if case .success(_, let message) = action {
            return message
        }
        return defaultSuccessMessage
    }
    
    private var dismissErrorAutomatically: Bool {
        if let firstError = binaryTypes.first(where: {
            if case .error = $0 { return true }
            return false
        }), case let .error(dismissAutomatically, _) = firstError {
            return dismissAutomatically
        }
        else {
            return true
        }
    }
    private var allowErrorManualDismiss: Bool {
        if let firstError = binaryTypes.first(where: {
            if case .error = $0 { return true }
            return false
        }), case let .error(_, allowManualDismiss) = firstError {
            return allowManualDismiss
        }
        else {
            return true
        }
    }
    private var dismissSuccessAutomatically: Bool {
        if let firstSuccess = binaryTypes.first(where: {
            if case .success = $0 { return true }
            return false
        }), case let .success(dismissAutomatically, _) = firstSuccess {
            return dismissAutomatically
        }
        else {
            return true
        }
    }
    private var allowSuccessManualDismiss: Bool {
        if let firstSuccess = binaryTypes.first(where: {
            if case .success = $0 { return true }
            return false
        }), case let .success(_, allowManualDismiss) = firstSuccess {
            return allowManualDismiss
        }
        else {
            return true
        }
    }
}

extension View {
    func actionSnackbar<D>(
        action: Binding<ActionState<D>>,
        events: [BinarySnackbarType],
        defaultErrorMessage: String = "Ein unbekannter Fehler ist aufgetreten",
        defaultSuccessMessage: String = "Operation erfolgreich",
        actionResetState: ActionState<D> = .idle
    ) -> some View {
        self.modifier(
            ActionSnackbarModifier(
                action: action,
                events: events,
                defaultErrorMessage: defaultErrorMessage,
                defaultSuccessMessage: defaultSuccessMessage,
                actionResetState: actionResetState
            )
        )
    }
}
