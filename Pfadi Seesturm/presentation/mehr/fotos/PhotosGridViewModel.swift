//
//  PhotosGridViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class PhotosGridViewModel {
    
    var photosState: UiState<[WordpressPhoto]> = .loading(subState: .idle)
    
    private let service: PhotosService
    private let album: WordpressPhotoGallery
    
    init(
        service: PhotosService,
        album: WordpressPhotoGallery
    ) {
        self.service = service
        self.album = album
    }
    
    func fetchPhotos(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                photosState = .loading(subState: .loading)
            }
        }
        
        let result = await service.getPhotos(albumId: album.id)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    photosState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    photosState = .error(message: "Fotos konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                photosState = .success(data: d)
            }
        }
    }
}
