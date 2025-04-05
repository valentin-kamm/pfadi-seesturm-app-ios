//
//  SnackbarView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct SnackbarView: View {
    
    @Binding var show: Bool
    let type: SnackbarType
    let message: String
    let config: SnackbarConfig
    let onDismiss: (() -> Void)?
    
    @State private var dismissTask: DispatchWorkItem?
            
    var body: some View {
        ZStack {
            if show {
                VStack {
                    Spacer()
                    CustomCardView(shadowColor: .clear, backgroundColor: type.backgroundColor) {
                        HStack(alignment: .center, spacing: 16) {
                            type.icon
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text(message)
                                .foregroundColor(.white)
                                .font(.callout)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                                .frame(alignment: .leading)
                                .layoutPriority(1)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.move(edge: .bottom))
                        .onAppear {
                            scheduleDismissal()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .onTapGesture {
                        if config.allowManualDismiss {
                            cancelAutomaticDismissal()
                            dismiss()
                        }
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
        if config.dismissAutomatically {
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
            show = false
        }
        if let od = onDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                od()
            }
        }
    }
}

enum SnackbarType {
    case error
    case info
    case success
    
    init (from: BinarySnackbarType) {
        switch from {
        case .error(_, _):
            self = .error
        case .success(_, _):
            self = .success
        }
    }
}
enum BinarySnackbarType {
    case error(dismissAutomatically: Bool, allowManualDismiss: Bool)
    case success(dismissAutomatically: Bool, allowManualDismiss: Bool)
}
struct SnackbarConfig {
    let dismissAutomatically: Bool
    let allowManualDismiss: Bool
}

extension SnackbarType {
    var backgroundColor: Color {
        switch self {
        case .error:
            .SEESTURM_RED
        case .info:
            .SEESTURM_BLUE
        case .success:
            .SEESTURM_GREEN
        }
    }
    var icon: Image {
        switch self {
        case .error:
            Image(systemName: "xmark.circle")
        case .info:
            Image(systemName: "info.circle")
        case .success:
            Image(systemName: "checkmark.circle")
        }
    }
}

#Preview {
    SnackbarPreview()
}

private struct SnackbarPreview: View {
    @State var showError = false
    @State var showInfo = false
    @State var showSuccess = false
    
    var body: some View {
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
    
}
