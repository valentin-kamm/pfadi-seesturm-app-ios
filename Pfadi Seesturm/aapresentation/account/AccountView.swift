//
//  AccountView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import FirebaseFunctions

struct AccountView: View {
    
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.accountModule) private var accountModule: AccountModule
    
    private let calendar: SeesturmCalendar
    init(
        calendar: SeesturmCalendar
    ) {
        self.calendar = calendar
    }
    
    var body: some View {
        NavigationStack(path: appState.accountNavigationPathBinding) {
            Group {
                switch appState.state.authState {
                case .signedOut(let state):
                    ScrollView {
                        switch state {
                        case .idle, .loading(_), .success(_, _):
                            LoggedOutView()
                        case .error(_, let message):
                            AuthErrorView(message: message)
                        }
                    }
                case .signedInWithHitobito(let user, _, let viewModel):
                    Leiterbereich(
                        viewModel: viewModel,
                        user: user,
                        calendar: calendar
                    )
                    .accountNavigationDestinations(
                        wordpressModule: wordpressModule,
                        accountModule: accountModule,
                        calendar: calendar,
                        leiterbereichViewModel: viewModel
                    )
                }
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.large)
            .customSnackbar(
                show: .constant(appState.state.authState.showInfoSnackbar),
                type: .info,
                message: "Die Anmeldung ist nur fürs Leitungsteam der Pfadi Seesturm möglich",
                dismissAutomatically: false,
                allowManualDismiss: false
            )
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

#Preview {
    AccountView(
        calendar: .termineLeitungsteam
    )
        .environmentObject(
            AppStateViewModel(
                authService: AuthService(
                    authRepository: AuthRepositoryImpl(
                        authApi: AuthApiImpl(
                            appConfig: Constants.OAUTH_CONFIG,
                            firebaseAuth: .auth()
                        )
                    ),
                    cloudFunctionsRepository: CloudFunctionsRepositoryImpl(
                        api: CloudFunctionsApiImpl(
                            functions: Functions.functions()
                        )
                    ),
                    firestoreRepository: FirestoreRepositoryImpl(
                        db: .firestore(),
                        api: FirestoreApiImpl(
                            db: .firestore()
                        )
                    )
                ),
                leiterbereichService: LeiterbereichService(
                    termineRepository: AnlaesseRepositoryImpl(
                        api: WordpressApiImpl(
                            baseUrl: Constants.SEESTURM_API_BASE_URL
                        )
                    ),
                    firestoreRepository: FirestoreRepositoryImpl(
                        db: .firestore(),
                        api: FirestoreApiImpl(
                            db: .firestore()
                        )
                    )
                ),
                universalLinksHandler: UniversalLinksHandler()
            )
        )
}
