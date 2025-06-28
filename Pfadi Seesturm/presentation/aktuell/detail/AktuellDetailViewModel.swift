//
//  AktuellDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class AktuellDetailViewModel {
    
    var postState: UiState<WordpressPost>
    
    private let service: AktuellService
    private let input: DetailInputType<Int, WordpressPost>
    
    init(
        service: AktuellService,
        input: DetailInputType<Int, WordpressPost>
    ) {
        self.service = service
        self.input = input
        
        switch input {
        case .id(_):
            self.postState = .loading(subState: .idle)
        case .object(let object):
            self.postState = .success(data: object)
        }
    }
    
    func fetchPost() async {
        
        guard case .id(let id) = input else {
            return
        }

        withAnimation {
            postState = .loading(subState: .loading)
        }
        let result = await service.fetchPost(postId: id)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    postState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    postState = .error(message: "Der Post konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                postState = .success(data: d)
            }
        }
    }
}
