//
//  SnackbarView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct SnackbarView: View {
    
    private let show: Binding<Bool>
    private let type: SeesturmSnackbarType
    private let message: String
    private let dismissAutomatically: Bool
    private let allowManualDismiss: Bool
    private let onDismiss: (() -> Void)?
    
    @State private var dismissTask: DispatchWorkItem?
    
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
    
    var body: some View {
        ZStack {
            if show.wrappedValue {
                VStack {
                    Spacer()
                    SnackbarContentView(
                        type: type,
                        message: message
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .onAppear {
                    scheduleDismissal()
                }
                .onTapGesture {
                    if allowManualDismiss {
                        cancelAutomaticDismissal()
                        dismiss()
                    }
                }
            }
        }
    }
    
    // function to schedule when the snackbar should be dismissed
    private func scheduleDismissal() {
        // cancel any existing dismissal task
        dismissTask?.cancel()
        // schedule if automatic dismissal is enabled
        if dismissAutomatically {
            dismissTask = DispatchWorkItem {
                dismiss()
            }
            if let dismissTask = dismissTask {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: dismissTask)
            }
        }
    }
    
    // function to cancel an automatic dismissal
    private func cancelAutomaticDismissal() {
        dismissTask?.cancel()
    }
    
    // function to dismiss the snackbar
    private func dismiss() {
        withAnimation(.easeInOut) {
            show.wrappedValue = false
        }
        if let od = onDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                od()
            }
        }
    }
}

#Preview {
    @Previewable @State var showError = false
    @Previewable @State var showInfo = false
    @Previewable @State var showSuccess = false
    
    VStack(spacing: 20) {
        Button("Show Error Snackbar") {
            showError = true
        }
        Button("Show Info Snackbar") {
            showInfo = true
        }
        Button("Show Success Snackbar") {
            showSuccess = true
        }
    }
    .customSnackbar(show: $showError, type: .error, message: "Ein Fehler ist aufgetreten", dismissAutomatically: false, allowManualDismiss: true, onDismiss: {})
    .customSnackbar(show: $showInfo, type: .info, message: "Irgend eine random Info.", dismissAutomatically: true, allowManualDismiss: true, onDismiss: {})
    .customSnackbar(show: $showSuccess, type: .success, message: "Irgend eine Erfolgsmeldung", dismissAutomatically: false, allowManualDismiss: false, onDismiss: {})
}
