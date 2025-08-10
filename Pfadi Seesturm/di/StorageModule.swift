//
//  StorageModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.08.2025.
//
import Foundation
import FirebaseStorage

protocol StorageModule {
    
    var storageApi: StorageApi { get }
    var storageRepository: StorageRepository { get }
}

class StorageModuleImpl: StorageModule {
    
    private let storage: Storage
    
    init(
        storage: Storage = Storage.storage()
    ) {
        self.storage = storage
    }
    
    lazy var storageApi: StorageApi = StorageApiImpl()
    lazy var storageRepository: StorageRepository = StorageRepositoryImpl(
        api: storageApi,
        storage: storage
    )
}
