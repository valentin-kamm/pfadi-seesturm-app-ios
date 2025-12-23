//
//  StorageApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import Foundation
import FirebaseStorage

protocol StorageApi {
    
    func uploadData(path: String, data: Data, contentType: String, onProgress: @escaping (Double) -> Void) async throws -> URL
    func deleteData(path: String) async throws
}

class StorageApiImpl: StorageApi {
    
    private let storage: Storage
    
    init(
        storage: Storage
    ) {
        self.storage = storage
    }
    
    func uploadData(path: String, data: Data, contentType: String, onProgress: @escaping (Double) -> Void) async throws -> URL {
        
        let reference = getReference(from: path)
        let metadata = StorageMetadata()
        metadata.contentType = contentType
        
        let _ = try await reference.putDataAsync(
            data,
            metadata: metadata
        ) { progress in
            if let p = progress {
                onProgress(p.fractionCompleted)
            }
        }
        
        return try await reference.downloadURL()
    }
    
    func deleteData(path: String) async throws {
        
        let reference = getReference(from: path)
        
        try await reference.delete()
    }
    
    private func getReference(from path: String) -> StorageReference {
        return storage.reference(withPath: path)
    }
}
