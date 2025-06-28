//
//  PhotoGalleryDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

struct WordpressPhotoGalleryDto: Codable {
    var title: String
    var id: String
    var thumbnail: String
}

extension WordpressPhotoGalleryDto {
    func toWordpressPhotoGallery() -> WordpressPhotoGallery {
        return WordpressPhotoGallery(
            title: title,
            id: id,
            thumbnailUrl: thumbnail
        )
    }
}
