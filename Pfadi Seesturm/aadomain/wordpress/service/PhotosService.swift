//
//  PhotosService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class PhotosService: WordpressService {
    
    let repository: PhotosRepository
    init(repository: PhotosRepository) {
        self.repository = repository
    }
    
    func getPfadijahre() async -> SeesturmResult<[WordpressPhotoGallery], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPfadijahre() },
            transform: { $0.map { $0.toWordpressPhotoGallery() } }
        )
    }
    func getAlbums(id: String) async -> SeesturmResult<[WordpressPhotoGallery], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getAlbums(id: id) },
            transform: { $0.map { $0.toWordpressPhotoGallery() } }
        )
    }
    func getPhotos(id: String) async -> SeesturmResult<[WordpressPhoto], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPhotos(id: id) },
            transform: { $0.map { $0.toWordpressPhoto() } }
        )
    }
}
