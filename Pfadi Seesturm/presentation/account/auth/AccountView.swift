//
//  AccountView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct AccountView<Leiterbereich: View>: View {
    
    private let authState: SeesturmAuthState
    private let leiterbereich: (FirebaseHitobitoUser) -> Leiterbereich
    private let path: Binding<NavigationPath>
    private let onAuthenticate: () async -> Void
    private let onResetAuthState: () -> Void
    
    init(
        authState: SeesturmAuthState,
        leiterbereich: @escaping (FirebaseHitobitoUser) -> Leiterbereich,
        path: Binding<NavigationPath>,
        onAuthenticate: @escaping () async -> Void,
        onResetAuthState: @escaping () -> Void
    ) {
        self.authState = authState
        self.leiterbereich = leiterbereich
        self.path = path
        self.onAuthenticate = onAuthenticate
        self.onResetAuthState = onResetAuthState
    }
    
    var body: some View {
        NavigationStack(path: path) {
            Group {
                switch authState {
                case .signedOut(let state):
                    ScrollView {
                        switch state {
                        case .idle, .loading(_), .success(_, _):
                            LoggedOutView(
                                authState: authState,
                                onAuthenticate: onAuthenticate
                            )
                        case .error(_, let message):
                            AuthErrorView(
                                message: message,
                                onResetAuthState: onResetAuthState
                            )
                        }
                    }
                case .signedInWithHitobito(let user, _):
                    leiterbereich(user)
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .customSnackbar(
                show: .constant(authState.showInfoSnackbar),
                type: .info,
                message: "Die Anmeldung ist nur fürs Leitungsteam der Pfadi Seesturm möglich",
                dismissAutomatically: false,
                allowManualDismiss: false
            )
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview("Idle") {
    AccountView(
        authState: .signedOut(state: .idle),
        leiterbereich: { _ in EmptyView() },
        path: .constant(NavigationPath()),
        onAuthenticate: {},
        onResetAuthState: {}
    )
}
#Preview("Loading") {
    AccountView(
        authState: .signedOut(state: .loading(action: ())),
        leiterbereich: { _ in EmptyView() },
        path: .constant(NavigationPath()),
        onAuthenticate: {},
        onResetAuthState: {}
    )
}
#Preview("Error") {
    AccountView(
        authState: .signedOut(state: .error(action: (), message: "Hallo")),
        leiterbereich: { _ in EmptyView() },
        path: .constant(NavigationPath()),
        onAuthenticate: {},
        onResetAuthState: {}
    )
}
