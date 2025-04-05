//
//  PhotosRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

protocol PhotosRepository {
    func getPfadijahre() async throws -> [WordpressPhotoGalleryDto]
    func getAlbums(id: String) async throws -> [WordpressPhotoGalleryDto]
    func getPhotos(id: String) async throws -> [WordpressPhotoDto]
}
