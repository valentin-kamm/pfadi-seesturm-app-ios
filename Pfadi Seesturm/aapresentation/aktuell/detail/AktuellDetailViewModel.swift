//
//  AktuellDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI

class AktuellDetailViewModel: StateManager<UiState<WordpressPost>> {
    
    private let service: AktuellService
    let input: DetailInputType<Int, WordpressPost>
    init(
        service: AktuellService,
        input: DetailInputType<Int, WordpressPost>
    ) {
        self.service = service
        self.input = input
        super.init(initialState: .loading(subState: .idle))
    }
        
    // function to fetch the desired post
    func fetchPost() async {
        switch input {
        case .id(let id):
            updateState { state in
                state = .loading(subState: .loading)
            }
            let result = await service.fetchPost(postId: id)
            switch result {
            case .error(let e):
                switch e {
                case .cancelled:
                    updateState { state in
                        state = .loading(subState: .retry)
                    }
                default:
                    updateState { state in
                        state = .error(message: "Der Post konnte nicht geladen werden. \(e.defaultMessage)")
                    }
                }
            case .success(let d):
                updateState { state in
                    state = .success(data: d)
                }
            }
        case .object(let wordpressPost):
            updateState { state in
                state = .success(data: wordpressPost)
            }
        }
    }
}
