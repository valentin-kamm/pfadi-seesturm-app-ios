//
//  WordpressRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//

import Foundation

protocol AktuellRepository {
    func getPosts(start: Int, length: Int) async throws -> WordpressPostsDto
    func getPost(postId: Int) async throws -> WordpressPostDto
    func getLatestPost() async throws -> WordpressPostDto
}
