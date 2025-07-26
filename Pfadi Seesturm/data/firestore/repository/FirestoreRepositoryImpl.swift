//
//  FirestoreRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//

import FirebaseFirestore

class FirestoreRepositoryImpl: FirestoreRepository {
    
    private let db: Firestore
    private let api: FirestoreApi
    
    init(
        db: Firestore,
        api: FirestoreApi
    ) {
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
    
    func performTransaction<T: FirestoreDto>(
        type: T.Type,
        document: SeesturmFirestoreDocument,
        forceNewCreatedDate: Bool,
        update: @escaping (T) throws -> T
    ) async throws {
        try await api.performTransaction(type: type, document: documentReference(for: document), forceNewCreatedDate: forceNewCreatedDate, update: update)
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
    
    func readCollection<T: FirestoreDto>(collection: SeesturmFirestoreCollection) async throws -> [T] {
        return try await api.readCollection(collection: collectionReference(for: collection))
    }
    
    func deleteDocument(document: SeesturmFirestoreDocument) async throws {
        try await api.deleteDocument(document: documentReference(for: document))
    }
    
    func deleteDocuments(documents: [SeesturmFirestoreDocument]) async throws {
        try await api.deleteDocuments(documents: documents.map { documentReference(for: $0) })
    }
    
    func deleteAllDocuments(in collection: SeesturmFirestoreCollection) async throws {
        try await api.deleteAllDocuments(in: collectionReference(for: collection))
    }
    
    private func collectionReference(for collection: SeesturmFirestoreCollection) -> CollectionReference {
        switch collection {
        case .abmeldungen:
            db.collection("abmeldungen")
        case .foodOrders:
            db.collection("leiterbereichFoodOrders").document("food").collection("orders")
        case .schopflialarm:
            db.collection("schopflialarm")
        case .schopflialarmReactions:
            documentReference(for: .schopflialarm).collection("reactions")
        case .users:
            db.collection("users")
        case .aktivitaetTemplates:
            db.collection("aktivitaetTemplates")
        }
    }
    private func documentReference(for document: SeesturmFirestoreDocument) -> DocumentReference {
        switch document {
        case .abmeldung(let id):
            collectionReference(for: .abmeldungen).document(id)
        case .order(let id):
            collectionReference(for: .foodOrders).document(id)
        case .schopflialarm:
            collectionReference(for: .schopflialarm).document("schopflialarm")
        case .user(let id):
            collectionReference(for: .users).document(id)
        case .aktivitaetTemplate(let id):
            collectionReference(for: .aktivitaetTemplates).document(id)
        }
    }
}
