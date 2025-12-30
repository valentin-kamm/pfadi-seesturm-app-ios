//
//  StorageModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

import SwiftUI
import FirebaseStorage

protocol StorageModule {
    
    var storageApi: StorageApi { get }
    var storageRepository: StorageRepository { get }
    var profilePictureService: ProfilePictureService { get }
}

class StorageModuleImpl: StorageModule {
    
    private let firestoreRepository: FirestoreRepository
    
    init(
        firestoreRepository: FirestoreRepository
    ) {
        self.firestoreRepository = firestoreRepository
    }
    
    lazy var storageApi: StorageApi = StorageApiImpl(storage: Storage.storage())
    
    lazy var storageRepository: StorageRepository = StorageRepositoryImpl(api: storageApi)
    
    lazy var profilePictureService: ProfilePictureService = ProfilePictureService(
        storageRepository: storageRepository,
        firestoreRepository: firestoreRepository
    )
}
