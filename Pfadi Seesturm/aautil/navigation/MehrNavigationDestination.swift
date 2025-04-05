//
//  MehrNavigationDestination.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//
import SwiftUI
import SwiftData

enum MehrNavigationDestination: NavigationDestination {
    case pfadijahre
    case albums(album: WordpressPhotoGallery)
    case photos(album: WordpressPhotoGallery)
    case dokumente
    case luuchtturm
    case leitungsteam(stufe: String)
    case pushNotifications
    case gespeichertePersonen
}

struct MehrNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let viewModel: PfadijahreViewModel
    private let modelContext: ModelContext
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        viewModel: PfadijahreViewModel,
        modelContext: ModelContext
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.viewModel = viewModel
        self.modelContext = modelContext
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: MehrNavigationDestination.self) { destination in
            switch destination {
            case .pfadijahre:
                PfadijahreView(viewModel: viewModel)
            case .albums(let album):
                GalleriesView(
                    viewModel: GalleriesViewModel(
                        service: wordpressModule.photosService,
                        pfadijahr: album
                    ),
                    pfadijahr: album
                )
            case .photos(let album):
                PhotosGridView(
                    viewModel: PhotosGridViewModel(
                        service: wordpressModule.photosService,
                        album: album
                    ),
                    gallery: album
                )
            case .dokumente:
                DokumenteView(
                    viewModel: DokumenteViewModel(
                        service: wordpressModule.documentsService
                    )
                )
            case .luuchtturm:
                LuuchtturmView(
                    viewModel: LuuchtturmViewModel(
                        service: wordpressModule.documentsService
                    )
                )
            case .leitungsteam(_):
                LeitungsteamView(
                    viewModel: LeitungsteamViewModel(
                        service: wordpressModule.leitungsteamService
                    ),
                    passedStufe: "Abteilungsleitung"
                )
            case .pushNotifications:
                PushNotificationVerwaltenView(
                    viewModel: PushNotificationVerwaltenViewModel(
                        service: fcmModule.fcmSubscriptionService,
                        modelContext: modelContext
                    )
                )
            case .gespeichertePersonen:
                GespeichertePersonenView()
            }
        }
    }
}

extension View {
    func mehrNavigationDestinations(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        viewModel: PfadijahreViewModel,
        modelContext: ModelContext
    ) -> some View {
        self.modifier(
            MehrNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                viewModel: viewModel,
                modelContext: modelContext
            )
        )
    }
}
