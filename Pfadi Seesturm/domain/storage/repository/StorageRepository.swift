//
//  StorageRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.08.2025.
//
import Foundation
import FirebaseStorage

protocol StorageRepository {
    
    func uploadData(item: StorageItem, metadata: StorageMetadata?, onProgress: @escaping (Double) -> Void) async throws -> URL
}
