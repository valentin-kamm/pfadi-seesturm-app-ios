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
    
    @EnvironmentObject private var appState: AppStateViewModel
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    @Environment(\.fcmModule) private var fcmModule: FCMModule
    
    @State private var viewModel: GalleriesViewModel
    
    init(
        viewModel: GalleriesViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: appState.path(for: .mehr)) {
            MehrContentView(
                pfadijahreState: viewModel.galleryState
            )
            .task {
                if viewModel.galleryState.taskShouldRun {
                    await viewModel.fetchGalleries(isPullToRefresh: false)
                }
            }
            .mehrNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                viewModel: viewModel
            )
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

private struct MehrContentView: View {
    
    private let pfadijahreState: UiState<[WordpressPhotoGallery]>
    
    init(
        pfadijahreState: UiState<[WordpressPhotoGallery]>
    ) {
        self.pfadijahreState = pfadijahreState
    }
    
    @AppStorage("theme") private var selectedTheme: String = "system"
    private let footerText = """
        Pfadi Seesturm \(String(Calendar.current.component(.year, from: Date())))
        app@seesturm\u{200B}.ch
        
        \((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String != nil && Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String != nil) ? ("App-Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)) \(Constants.IS_DEBUG ? "(Debug)" : "")") : "")
        """
    private let belegungsplanUrl = URL(string: "https://api.belegungskalender-kostenlos.de/kalender.php?kid=24446")!
    private let pfadiheimInfoUrl = URL(string: "https://seesturm.ch/pfadiheim/")!
    private let pfadiheimMailUrl = URL(string: "mailto:pfadiheim@seesturm.ch")!
    
    var body: some View {
        Form {
            Section {
                NavigationLink(value: MehrNavigationDestination.pfadijahre(forceReload: false)) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.SEESTURM_GREEN)
                        Text("Fotos")
                    }
                }
                if !pfadijahreState.isError {
                    MehrHorizontalPhotoScrollView(
                        photosState: pfadijahreState
                    )
                }
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
            } header: {
                Text("Infos und Medien")
            }
            Section {
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
            } header: {
                Text("Pfadiheim")
            }
            Section {
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
            } header: {
                Text("Einstellungen")
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
        .navigationTitle("Mehr")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        MehrContentView(
            pfadijahreState: .loading(subState: .loading)
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        MehrContentView(
            pfadijahreState: .error(message: "Schwerer Fehler")
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        MehrContentView(
            pfadijahreState: .success(data: [
                WordpressPhotoGallery(
                    title: "Test 1",
                    id: UUID().uuidString,
                    thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg"
                ),
                WordpressPhotoGallery(
                    title: "Test 2",
                    id: UUID().uuidString,
                    thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2022/04/190404_Infobroschuere-Pfadi-Thurgau-pdf-212x300.jpg"
                ),
                WordpressPhotoGallery(
                    title: "Test 3",
                    id: UUID().uuidString,
                    thumbnailUrl: "https://seesturm.ch/wp-content/uploads/2017/10/Wicky2021-scaled.jpg"
                )
            ])
        )
    }
}
