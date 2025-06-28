//
//  PhotosService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class PhotosService: WordpressService {
    
    private let repository: PhotosRepository
    
    init(repository: PhotosRepository) {
        self.repository = repository
    }
    
    func getPfadijahre() async -> SeesturmResult<[WordpressPhotoGallery], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPfadijahre() },
            transform: { $0.map { $0.toWordpressPhotoGallery() } }
        )
    }
    
    func getAlbums(pfadijahrId: String) async -> SeesturmResult<[WordpressPhotoGallery], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getAlbums(pfadijahrId: pfadijahrId) },
            transform: { $0.map { $0.toWordpressPhotoGallery() } }
        )
    }
    
    func getPhotos(albumId: String) async -> SeesturmResult<[WordpressPhoto], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getPhotos(albumId: albumId) },
            transform: { $0.map { $0.toWordpressPhoto() } }
        )
    }
}
