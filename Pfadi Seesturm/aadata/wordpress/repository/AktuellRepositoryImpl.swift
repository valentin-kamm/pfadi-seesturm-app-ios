//
//  WordpressRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//

class AktuellRepositoryImpl: AktuellRepository {
    
    let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getPosts(start: Int, length: Int) async throws -> WordpressPostsDto {
        return try await api.getPosts(start: start, length: length)
    }
    func getPost(postId: Int) async throws -> WordpressPostDto {
        return try await api.getPost(postId: postId)
    }
    func getLatestPost() async throws -> WordpressPostDto {
        if let latestPost = try await api.getPosts(start: 0, length: 1).posts.first {
            return latestPost
        }
        else {
            throw PfadiSeesturmAppError.invalidResponse(message: "Post existiert nicht.")
        }
    }
}
