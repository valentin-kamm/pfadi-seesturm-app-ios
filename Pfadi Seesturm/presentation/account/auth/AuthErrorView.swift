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
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.SEESTURM_RED)
                Text("Beim Anmelden ist ein Fehler aufgetreten")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                SeesturmButton(
                    type: .primary,
                    action: .sync(action: onResetAuthState),
                    title: "Zurück"
                )
            }
            .padding()
            .padding(.vertical, 8)
        }
        .padding()
    }
}
