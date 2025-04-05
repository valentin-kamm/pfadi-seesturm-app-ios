//
//  AktuellService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import Foundation

class AktuellService: WordpressService {
    
    let repository: AktuellRepository
    init(repository: AktuellRepository) {
        self.repository = repository
    }
    
    func fetchPosts(start: Int, length: Int) async -> SeesturmResult<WordpressPosts, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPosts(start: start, length: length) },
            transform: { try $0.toWordpressPosts() }
        )
    }
    func fetchMorePosts(start: Int, length: Int) async -> SeesturmResult<WordpressPosts, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPosts(start: start, length: length) },
            transform: { try $0.toWordpressPosts() }
        )
    }
    func fetchPost(postId: Int) async -> SeesturmResult<WordpressPost, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPost(postId: postId) },
            transform: { try $0.toWordpressPost() }
        )
    }
    func fetchLatestPost() async -> SeesturmResult<WordpressPost, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getLatestPost() },
            transform: { try $0.toWordpressPost() }
        )
    }
    
}
