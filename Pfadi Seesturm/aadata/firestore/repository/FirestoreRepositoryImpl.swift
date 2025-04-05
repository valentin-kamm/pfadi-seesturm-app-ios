//
//  FirestoreRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//

import FirebaseFirestore

class FirestoreRepositoryImpl: FirestoreRepository {
    
    let db: Firestore
    let api: FirestoreApi
    
    init(db: Firestore, api: FirestoreApi) {
        self.db = db
        self.api = api
    }
    
    func observeDocument<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>> {
        return api.observeDocument(type: type, document: documentReference(for: document))
    }
    
    func observeCollection<T: FirestoreDto>(
        type: T.Type,
        collection: SeesturmFirestoreCollection,
        filter: ((Query) -> Query)? = nil
    ) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>> {
        return api.observeCollection(type: type, collection: collectionReference(for: collection), filter: filter)
    }
    
    func performTransaction<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument, update: @escaping (T) throws -> T) async throws {
        try await api.performTransaction(type: type, document: documentReference(for: document), update: update)
    }
    
    func insertDocument<T: FirestoreDto>(object: T, collection: SeesturmFirestoreCollection) async throws {
        try await api.insertDocument(object: object, collection: collectionReference(for: collection))
    }
    
    func upsertDocument<T: FirestoreDto>(object: T, document: SeesturmFirestoreDocument) async throws {
        try await api.upsertDocument(object: object, document: documentReference(for: document))
    }
    
    func readDocument<T: FirestoreDto>(document: SeesturmFirestoreDocument) async throws -> T {
        return try await api.readDocument(document: documentReference(for: document))
    }
    
    func deleteDocument(document: SeesturmFirestoreDocument) async throws {
        try await api.deleteDocument(document: documentReference(for: document))
    }
    
    func deleteDocuments(documents: [SeesturmFirestoreDocument]) async throws {
        try await api.deleteDocuments(documents: documents.map { documentReference(for: $0) })
    }
    
    private func collectionReference(for collection: SeesturmFirestoreCollection) -> CollectionReference {
        switch collection {
        case .users:
            db.collection("users")
        case .leiterbereich:
            db.collection("leiterbereich")
        case .abmeldungen:
            db.collection("abmeldungen")
        case .foodOrders:
            db.collection("leiterbereich").document("food").collection("orders")
        }
    }
    private func documentReference(for document: SeesturmFirestoreDocument) -> DocumentReference {
        switch document {
        case .food:
            collectionReference(for: .leiterbereich).document("food")
        case .order(let id):
            collectionReference(for: .foodOrders).document(id)
        case .schöpflialarm:
            collectionReference(for: .leiterbereich).document("schopflialarm")
        case .user(let id):
            collectionReference(for: .users).document(id)
        case .abmeldung(let id):
            collectionReference(for: .abmeldungen).document(id)
        }
    }
}

enum SeesturmFirestoreCollection {
    case users
    case leiterbereich
    case abmeldungen
    case foodOrders
}
enum SeesturmFirestoreDocument {
    case food
    case order(id: String)
    case schöpflialarm
    case user(id: String)
    case abmeldung(id: String)
}
