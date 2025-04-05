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
    func deleteDocument(document: SeesturmFirestoreDocument) async throws
    func deleteDocuments(documents: [SeesturmFirestoreDocument]) async throws
    func observeDocument<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>>
    func observeCollection<T: FirestoreDto>(
        type: T.Type,
        collection: SeesturmFirestoreCollection,
        filter: ((Query) -> Query)?
    ) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>>
    func performTransaction<T: FirestoreDto>(type: T.Type, document: SeesturmFirestoreDocument, update: @escaping (T) throws -> T) async throws
}
