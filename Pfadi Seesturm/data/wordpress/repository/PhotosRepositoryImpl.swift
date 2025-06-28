//
//  PhotosRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class PhotosRepositoryImpl: PhotosRepository {
    
    private let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getPfadijahre() async throws -> [WordpressPhotoGalleryDto] {
        return try await api.getPhotosPfadijahre()
    }
    
    func getAlbums(pfadijahrId: String) async throws -> [WordpressPhotoGalleryDto] {
        return try await api.getPhotosAlbums(id: pfadijahrId)
    }
    
    func getPhotos(albumId: String) async throws -> [WordpressPhotoDto] {
        return try await api.getPhotos(id: albumId)
    }
}
