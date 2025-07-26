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
    case albums(pfadijahr: WordpressPhotoGallery)
    case photos(album: WordpressPhotoGallery)
    case dokumente
    case luuchtturm
    case leitungsteam(stufe: String)
    case pushNotifications
    case gespeichertePersonen
}

private struct MehrNavigationDestinations: ViewModifier {
    
    private let wordpressModule: WordpressModule
    private let fcmModule: FCMModule
    private let viewModel: GalleriesViewModel
    
    init(
        wordpressModule: WordpressModule,
        fcmModule: FCMModule,
        viewModel: GalleriesViewModel
    ) {
        self.wordpressModule = wordpressModule
        self.fcmModule = fcmModule
        self.viewModel = viewModel
    }
    
    func body(content: Content) -> some View {
        content.navigationDestination(for: MehrNavigationDestination.self) { destination in
            switch destination {
            case .pfadijahre:
                GalleriesViewPfadijahre(
                    viewModel: viewModel,
                    navigationDestination: { pfadijahr in
                        MehrNavigationDestination.albums(pfadijahr: pfadijahr)
                    }
                )
            case .albums(let pfadijahr):
                GalleriesViewAlbums(
                    viewModel: GalleriesViewModel(
                        service: wordpressModule.photosService,
                        type: .albums(pfadijahr: pfadijahr)
                    ),
                    navigationDestination: { album in
                        MehrNavigationDestination.photos(album: album)
                    },
                    pfadijahr: pfadijahr
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
                DocumentsView(
                    viewModel: DocumentsViewModel(
                        service: wordpressModule.documentsService,
                        documentType: .documents
                    ),
                    documentType: .documents
                )
            case .luuchtturm:
                DocumentsView(
                    viewModel: DocumentsViewModel(
                        service: wordpressModule.documentsService,
                        documentType: .luuchtturm
                    ),
                    documentType: .luuchtturm
                )
            case .leitungsteam(_):
                LeitungsteamView(
                    viewModel: LeitungsteamViewModel(
                        service: wordpressModule.leitungsteamService
                    )
                )
            case .pushNotifications:
                PushNotificationVerwaltenView(
                    viewModel: PushNotificationVerwaltenViewModel(
                        service: fcmModule.fcmService
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
        viewModel: GalleriesViewModel
    ) -> some View {
        self.modifier(
            MehrNavigationDestinations(
                wordpressModule: wordpressModule,
                fcmModule: fcmModule,
                viewModel: viewModel
            )
        )
    }
}
