//
//  PhotosGridViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

class PhotosGridViewModel: StateManager<UiState<[WordpressPhoto]>> {
    
    private let service: PhotosService
    private let album: WordpressPhotoGallery
    init(
        service: PhotosService,
        album: WordpressPhotoGallery
    ) {
        self.service = service
        self.album = album
        super.init(initialState: .loading(subState: .idle))
    }
    
    // function to fetch pfadijahre
    func fetchPhotos(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state = .loading(subState: .loading)
            }
        }
        let result = await service.getPhotos(id: album.id)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state = .error(message: "Fotos konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state = .success(data: d)
            }
        }
    }
}
