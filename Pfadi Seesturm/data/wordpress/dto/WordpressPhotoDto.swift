//
//  WordpressPhotoDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import Foundation

struct WordpressPhotoDto: Codable {
    var thumbnail: String
    var original: String
    var orientation: String
    var height: Int
    var width: Int
}

extension WordpressPhotoDto {
    func toWordpressPhoto() -> WordpressPhoto {
        return WordpressPhoto(
            id: UUID(),
            thumbnailUrl: thumbnail,
            originalUrl: original,
            orientation: orientation,
            height: height,
            width: width
        )
    }
}
