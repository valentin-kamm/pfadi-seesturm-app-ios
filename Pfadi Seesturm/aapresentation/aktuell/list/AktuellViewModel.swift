//
//  WordpressAPIUtil.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

class AktuellViewModel: StateManager<AktuellListState> {
    
    private let numberOfPostsPerPage: Int = 5
    
    private let service: AktuellService
    init(service: AktuellService) {
        self.service = service
        super.init(initialState: AktuellListState())
    }
    
    // calculated properties
    var postsLoadedCount: Int {
        switch (state.result) {
        case .success(data: let data, subState: _):
            return data.count
        default:
            return 0
        }
    }
    var hasMorePosts: Bool {
        switch state.result {
        case .success(_, _):
            return postsLoadedCount < state.totalPostsAvailable
        default:
            return false
        }
    }
    
    // function to fetch the initial set of posts
    func getPosts(isPullToRefresh: Bool) async {
        if !isPullToRefresh {
            updateState { state in
                state.result = .loading(subState: .loading)
            }
        }
        let result = await service.fetchPosts(start: 0, length: numberOfPostsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.result = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.result = .error(message: "Posts konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.result = .success(data: d.posts, subState: .success)
                state.totalPostsAvailable = d.totalPosts
            }
        }
    }
    
    // function to fetch more posts
    func getMorePosts() async {
        
        updateState { state in
            state.result = state.result.updateSubState(.loading)
        }
        let result = await service.fetchMorePosts(start: postsLoadedCount, length: numberOfPostsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.result = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.result = state.result.updateSubState(.error(message: "Es konnten nicht mehr Posts geladen werden. \(e.defaultMessage)"))
                }
            }
        case .success(let d):
            updateState { state in
                state.result = state.result.updateDataAndSubState(
                    { oldData in
                        return oldData + d.posts
                    },
                    .success
                )
                state.totalPostsAvailable = d.totalPosts
            }
        }
    }
}
