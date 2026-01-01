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
    var height: Int?
    var width: Int?
}

extension [WordpressPhotoDto] {
    func toWordpressPhotos() -> [WordpressPhoto] {
        let filteredPhotos = self.compactMap { photo in
            if let height = photo.height, let width = photo.width {
                return WordpressPhoto(
                    id: UUID(),
                    thumbnailUrl: photo.thumbnail,
                    originalUrl: photo.original,
                    orientation: photo.orientation,
                    height: height,
                    width: width
                )
            }
            else {
                return nil
            }
        }
        return filteredPhotos
    }
}
