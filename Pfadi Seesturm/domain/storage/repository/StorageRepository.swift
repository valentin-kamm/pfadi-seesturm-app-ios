//
//  StorageRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import Foundation

protocol StorageRepository {
    
    func uploadData(item: UploadStorageItem, onProgress: @escaping (Double) -> Void) async throws -> URL
    func deleteData(item: DeleteStorageItem) async throws
    
}
