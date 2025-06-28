//
//  WordpressPostsDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//

struct WordpressPostsDto: Codable {
    var totalPosts: Int
    var posts: [WordpressPostDto]
}

extension WordpressPostsDto {
    func toWordpressPosts() throws -> WordpressPosts {
        return WordpressPosts(
            postCount: totalPosts,
            posts: try posts.map { try $0.toWordpressPost() }
        )
    }
}
