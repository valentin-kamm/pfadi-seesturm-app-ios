//
//  FirestoreModule.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import SwiftUI
import FirebaseFirestore

protocol FirestoreModule {
    
    var db: Firestore { get }
    
    var firestoreApi: FirestoreApi { get }
    
    var firestoreRepository: FirestoreRepository { get }
}

class FirestoreModuleImpl: FirestoreModule {
    
    lazy var db: Firestore = Firestore.firestore()
    
    lazy var firestoreApi: FirestoreApi = FirestoreApiImpl(db: db)
    
    lazy var firestoreRepository: FirestoreRepository = FirestoreRepositoryImpl(db: db, api: firestoreApi)
    
}

struct FirestoreModuleKey: EnvironmentKey {
    static let defaultValue: FirestoreModule = FirestoreModuleImpl()
}
extension EnvironmentValues {
    var firestoreModule: FirestoreModule {
        get { self[FirestoreModuleKey.self] }
        set { self[FirestoreModuleKey.self] = newValue }
    }
}
