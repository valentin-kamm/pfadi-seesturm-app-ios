//
//  StorageRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import Foundation

class StorageRepositoryImpl: StorageRepository {
    
    private let api: StorageApi
    
    init(
        api: StorageApi
    ) {
        self.api = api
    }
    
    func uploadData(item: UploadStorageItem) async throws -> URL {
        return try await api.uploadData(
            path: item.path,
            data: item.data,
            contentType: item.contentType
        )
    }
    
    func deleteData(item: DeleteStorageItem) async throws {
        return try await api.deleteData(path: item.path)
    }
}
