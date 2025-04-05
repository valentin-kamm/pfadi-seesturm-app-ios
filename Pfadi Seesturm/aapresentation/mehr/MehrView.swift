//
//  MehrView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import SwiftData
import FirebaseFunctions

struct MehrView: View {
    
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.modelContext) var modelContext: ModelContext
    
    @StateObject var viewModel: PfadijahreViewModel
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    
    let footerText = """
        Pfadi Seesturm \(String(Calendar.current.component(.year, from: Date())))
        app@seesturm\u{200B}.ch
        
        \((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String != nil && Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String != nil) ? ("App-Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)) \(Constants.IS_DEBUG ? "(Debug)" : "")") : "")
        """
    
    // url's
    let belegungsplanUrl = URL(string: "https://api.belegungskalender-kostenlos.de/kalender.php?kid=24446")!
    let pfadiheimInfoUrl = URL(string: "https://seesturm.ch/pfadiheim/")!
    let pfadiheimMailUrl = URL(string: "mailto:pfadiheim@seesturm.ch")!
    
    // Auswahlmöglichkeiten für dark / light mode
    @AppStorage("theme") var selectedTheme: String = "system"
    
    var body: some View {
        NavigationStack(path: appState.mehrNavigationPathBinding) {
            Form {
                Section(header: Text("Infos und Medien")) {
                    NavigationLink(value: MehrNavigationDestination.pfadijahre) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Fotos")
                        }
                    }
                    // show a preview of the photos if no error occurs
                    .listRowSeparator(viewModel.state.isError ? .hidden : .automatic)
                    MehrHorizontalPhotoScrollView(viewModel: viewModel)
                    
                    NavigationLink(value: MehrNavigationDestination.dokumente) {
                        HStack {
                            Image(systemName: "doc.text")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Dokumente")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.luuchtturm) {
                        HStack {
                            Image(systemName: "magazine")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Lüüchtturm")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.leitungsteam(stufe: "Abteilungsleitung")) {
                        HStack {
                            Image(systemName: "person.crop.square.filled.and.at.rectangle")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Leitungsteam")
                        }
                    }
                }
                Section(header: Text("Pfadiheim")) {
                    Link(destination: belegungsplanUrl) {
                        HStack {
                            Image(systemName: "calendar")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Belegungsplan")
                        }
                    }
                    Link(destination: pfadiheimInfoUrl) {
                        HStack {
                            Image(systemName: "info.square")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Weitere Informationen")
                        }
                    }
                    Link(destination: pfadiheimMailUrl) {
                        HStack {
                            Image(systemName: "ellipsis.message")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Anfrage und Reservation")
                        }
                    }
                }
                Section(header: Text("Einstellungen")) {
                    NavigationLink(value: MehrNavigationDestination.pushNotifications) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Push-Nachrichten")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.gespeichertePersonen) {
                        HStack {
                            Image(systemName: "person.2")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Gespeicherte Personen")
                        }
                    }
                    // there is a bug with preferredColorScheme in iOS 18.0
                    // -> Do not include this feature when running this version
                    if !(ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 18 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 0) {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Picker("Erscheinungsbild", selection: $selectedTheme) {
                                Text("Hell")
                                    .tag("hell")
                                Text("Dunkel")
                                    .tag("dunkel")
                                Text("System")
                                    .tag("system")
                            }
                            .pickerStyle(.menu)
                            .tint(Color.SEESTURM_GREEN)
                        }
                    }
                }
                Section {
                    Link(destination: URL(string: Constants.FEEDBACK_FORM_URL)!) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Feedback zur App geben")
                        }
                    }
                    Link(destination: URL(string: Constants.DATENSCHUTZERKLAERUNG_URL)!) {
                        HStack {
                            Image(systemName: "doc.questionmark")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Datenschutzerklärung")
                        }
                    }
                }
                // display a footer
                Text(footerText)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .task {
                if viewModel.state.taskShouldRun {
                    await viewModel.fetchPfadijahre(isPullToRefresh: false)
                }
            }
            .navigationTitle("Mehr")
            .navigationBarTitleDisplayMode(.large)
            .mehrNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                viewModel: viewModel,
                modelContext: modelContext
            )
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

// separate view for scroll view of photos
struct MehrHorizontalPhotoScrollView: View {
    
    @ObservedObject var viewModel: PfadijahreViewModel
    @EnvironmentObject var appState: AppStateViewModel
    
    var body: some View {
        
        switch viewModel.state {
        case .loading(_):
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(1..<10) { _ in
                        PhotoGalleryLoadingCell(
                            size: 120,
                            withText: true
                        )
                    }
                }
            }
            .scrollDisabled(true)
        case .error(_):
            EmptyView()
        case .success(let pfadijahre):
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(pfadijahre.reversed(), id: \.id) { pfadijahr in
                        NavigationLink(value: MehrNavigationDestination.albums(album: pfadijahr)) {
                            PhotoGalleryCell(
                                size: 120,
                                thumbnailUrl: pfadijahr.thumbnail,
                                title: pfadijahr.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

#Preview {
    MehrView(
        viewModel: PfadijahreViewModel(
            service: PhotosService(
                repository: PhotosRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        )
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
