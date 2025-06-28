//
//  PhotosRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

protocol PhotosRepository {
    
    func getPfadijahre() async throws -> [WordpressPhotoGalleryDto]
    func getAlbums(pfadijahrId: String) async throws -> [WordpressPhotoGalleryDto]
    func getPhotos(albumId: String) async throws -> [WordpressPhotoDto]
}
