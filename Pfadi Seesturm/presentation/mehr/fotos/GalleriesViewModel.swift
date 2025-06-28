//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class GalleriesViewModel {
    
    var galleryState: UiState<[WordpressPhotoGallery]> = .loading(subState: .idle)
    
    private let service: PhotosService
    private let type: PhotoGalleriesType
    
    init(
        service: PhotosService,
        type: PhotoGalleriesType
    ) {
        self.service = service
        self.type = type
    }
    
    func fetchGalleries(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                galleryState = .loading(subState: .loading)
            }
        }
        
        let result: SeesturmResult<[WordpressPhotoGallery], NetworkError>
        
        switch type {
        case .pfadijahre:
            result = await service.getPfadijahre()
        case .albums(let pfadijahr):
            result = await service.getAlbums(pfadijahrId: pfadijahr.id)
        }
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    galleryState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    galleryState = .error(message: "Fotos konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                galleryState = .success(data: d)
            }
        }
    }
}
