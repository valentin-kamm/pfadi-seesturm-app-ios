//
//  StorageApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.08.2025.
//
import Foundation
import FirebaseStorage

protocol StorageApi {

    func uploadData(reference: StorageReference, data: Data, metadata: StorageMetadata?, onProgress: @escaping (Double) -> Void) async throws -> URL
}

class StorageApiImpl: StorageApi {
    
    func uploadData(reference: StorageReference, data: Data, metadata: StorageMetadata? = nil, onProgress: @escaping (Double) -> Void) async throws -> URL {
        
        let _ = try await reference.putDataAsync(
            data,
            metadata: metadata) { progress in
                if let progress = progress {
                    onProgress(progress.fractionCompleted)
                }
            }
        
        return try await reference.downloadURL()
    }
}
