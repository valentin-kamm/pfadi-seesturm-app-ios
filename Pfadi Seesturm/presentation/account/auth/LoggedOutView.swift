//
//  LoggedOutView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI
import FirebaseFunctions
import SwiftData

struct LoggedOutView: View {
    
    private let authState: SeesturmAuthState
    private let onAuthenticate: () async -> Void
    
    init(
        authState: SeesturmAuthState,
        onAuthenticate: @escaping () async -> Void
    ) {
        self.authState = authState
        self.onAuthenticate = onAuthenticate
    }
        
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Image("SeesturmLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Login")
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                Text("Melde dich mit MiData an um fortzufahren.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                SeesturmButton(
                    type: .primary,
                    action: .async(action: onAuthenticate),
                    title: "Login mit MiData",
                    icon: .custom(name: "midataLogo", width: 30, height: 30),
                    isLoading: authState.signInButtonIsLoading
                )
            }
            .padding()
            .padding(.vertical, 8)
        }
        .padding()
    }
}

#Preview {
    LoggedOutView(
        authState: .signedOut(state: .idle),
        onAuthenticate: {}
    )
}
