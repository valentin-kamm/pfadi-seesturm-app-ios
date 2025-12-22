//
//  StorageRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.08.2025.
//
import Foundation
import FirebaseStorage

class StorageRepositoryImpl: StorageRepository {
    
    private let api: StorageApi
    private let storage: Storage
    
    init(
        api: StorageApi,
        storage: Storage
    ) {
        self.api = api
        self.storage = storage
    }
    
    func uploadData(item: UploadStorageItem, onProgress: @escaping (Double) -> Void) async throws -> URL {
        return try await api.uploadData(
            reference: item.getReference(storage: storage),
            data: item.data,
            metadata: item.metadata,
            onProgress: onProgress
        )
    }
    
    func deleteData(item: DeleteStorageItem) async throws {
        return try await api.deleteData(reference: item.getReference(storage: storage))
    }
}
