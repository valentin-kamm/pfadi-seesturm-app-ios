//
//  LoggedOutView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI
import FirebaseFunctions

struct LoggedOutView: View {
    
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.authModule) var authModule: AuthModule
        
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Image("SeesturmLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                Text("Login")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                Text("Melde dich mit MiData an um fortzufahren.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 8)
                SeesturmButton(
                    style: .primary,
                    action: .async(action: {
                        await appState.authenticate()
                    }),
                    title: "Login mit MiData",
                    icon: .custom(name: "midataLogo", width: 30, height: 30),
                    isLoading: appState.state.authState.signInButtonIsLoading
                )
            }
            .padding()
            .padding(.vertical, 8)
        }
        .padding()
    }
    
}

#Preview {
    LoggedOutView()
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
