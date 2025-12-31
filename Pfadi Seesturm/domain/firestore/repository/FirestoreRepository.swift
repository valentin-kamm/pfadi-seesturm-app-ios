//
//  FirestoreRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import FirebaseFirestore

protocol FirestoreRepository {
    
    func insertDocument<T: FirestoreDto>(object: T, collection: SeesturmFirestoreCollection) async throws
    func upsertDocument<T: FirestoreDto>(object: T, document: SeesturmFirestoreDocument) async throws
    func readDocument<T: FirestoreDto>(document: SeesturmFirestoreDocument) async throws -> T
    func readCollection<T: FirestoreDto>(collection: SeesturmFirestoreCollection, filter: ((Query) -> Query)?) async throws -> [T]
    func deleteDocument(document: SeesturmFirestoreDocument) async throws
    func deleteDocuments(documents: [SeesturmFirestoreDocument]) async throws
    func deleteAllDocuments(in collection: SeesturmFirestoreCollection) async throws
    func observeDocument<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>>
    func observeCollection<T: FirestoreDto>(type: T.Type, collection: SeesturmFirestoreCollection, filter: ((Query) -> Query)?) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>>
    func performTransaction<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument, forceNewCreatedDate: Bool, update: @escaping (T) throws -> T) async throws
}

enum SeesturmFirestoreCollection {
    case users
    case abmeldungen
    case foodOrders
    case schopflialarm
    case schopflialarmReactions
    case aktivitaetTemplates
}

enum SeesturmFirestoreDocument {
    case user(id: String)
    case abmeldung(id: String)
    case schopflialarm
    case order(id: String)
    case aktivitaetTemplate(id: String)
}
