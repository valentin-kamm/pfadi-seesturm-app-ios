//
//  AktuellViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//
import SwiftUI
import Observation

@Observable
@MainActor
class AktuellViewModel {
    
    var eventsState: InfiniteScrollUiState<[WordpressPost]> = .loading(subState: .idle)
    var totalPostsAvailable: Int = 0
    
    private let service: AktuellService
    
    init(
        service: AktuellService
    ) {
        self.service = service
    }
    
    private let numberOfPostsPerPage: Int = 5
    
    private var postsLoadedCount: Int {
        switch eventsState {
        case .success(let data, subState: _):
            return data.count
        default:
            return 0
        }
    }
    var hasMorePosts: Bool {
        switch eventsState {
        case .success(_, _):
            return postsLoadedCount < totalPostsAvailable
        default:
            return false
        }
    }
    
    func getPosts(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                eventsState = .loading(subState: .loading)
            }
        }
        let result = await service.fetchPosts(start: 0, length: numberOfPostsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    eventsState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    eventsState = .error(message: "Posts konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                eventsState = .success(data: d.posts, subState: .success)
                totalPostsAvailable = d.postCount
            }
        }
    }
    
    func getMorePosts() async {
        
        withAnimation {
            eventsState = eventsState.updateSubState(.loading)
        }
        
        let result = await service.fetchMorePosts(start: postsLoadedCount, length: numberOfPostsPerPage)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    eventsState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    eventsState = eventsState.updateSubState(.error(message: "Es konnten nicht mehr Posts geladen werden. \(e.defaultMessage)"))
                }
            }
        case .success(let d):
            withAnimation {
                eventsState = eventsState.updateDataAndSubState({ oldData in
                    return oldData + d.posts
                }, .success)
                totalPostsAvailable = d.postCount
            }
        }
    }
}
