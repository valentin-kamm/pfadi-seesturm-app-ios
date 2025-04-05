//
//  PfadijahreViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

class PfadijahreViewModel: StateManager<UiState<[WordpressPhotoGallery]>> {
    
    private let service: PhotosService
    init(
        service: PhotosService
    ) {
        self.service = service
        super.init(initialState: .loading(subState: .idle))
    }
        
    // function to fetch pfadijahre
    func fetchPfadijahre(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state = .loading(subState: .loading)
            }
        }
        let result = await service.getPfadijahre()
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
