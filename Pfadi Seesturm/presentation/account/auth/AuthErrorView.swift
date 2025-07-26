//
//  AuthErrorView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import SwiftUI

struct AuthErrorView: View {
    
    private let message: String
    private let onResetAuthState: () -> Void
    
    init(
        message: String,
        onResetAuthState: @escaping () -> Void
    ) {
        self.message = message
        self.onResetAuthState = onResetAuthState
    }
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            ContentUnavailableView(
                label: {
                    Label("Beim Anmelden ist ein Fehler aufgetreten", systemImage: "person.crop.circle.badge.exclamationmark")
                },
                description: {
                    Text(message)
                },
                actions: {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: onResetAuthState),
                        title: "Zurück"
                    )
                }
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}

#Preview {
    AuthErrorView(
        message: "Schwerer Fehler",
        onResetAuthState: {}
    )
}
