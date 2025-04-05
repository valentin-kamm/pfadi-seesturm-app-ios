//
//  FirestoreApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import Foundation
import FirebaseFirestore

protocol FirestoreApi {
    
    var db: Firestore { get }
    
    func insertDocument<T: FirestoreDto>(object: T, collection: CollectionReference) async throws
    func upsertDocument<T: FirestoreDto>(object: T, document: DocumentReference) async throws
    func readDocument<T: FirestoreDto>(document: DocumentReference) async throws -> T
    func deleteDocument(document: DocumentReference) async throws
    func deleteDocuments(documents: [DocumentReference]) async throws
    func observeDocument<T: FirestoreDto>(type: T.Type, document: DocumentReference) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>>
    func observeCollection<T: FirestoreDto>(
        type: T.Type,
        collection: CollectionReference,
        filter: ((Query) -> Query)?
    ) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>>
    func performTransaction<T: FirestoreDto>(type: T.Type, document: DocumentReference, update: @escaping (T) throws -> T) async throws
}

class FirestoreApiImpl: FirestoreApi {
    
    internal let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func performTransaction<T: FirestoreDto>(type: T.Type, document: DocumentReference, update: @escaping (T) throws -> T) async throws {
        
        let _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(document)
                let currentData = try snapshot.data(as: T.self)
                let newData = try update(currentData)
                try transaction.setData(from: newData, forDocument: document)
                return true
            }
            catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func observeCollection<T: FirestoreDto>(
        type: T.Type,
        collection: CollectionReference,
        filter: ((Query) -> Query)? = nil
    ) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>> {
        
        var query: Query = collection
        if let f = filter {
            query = f(query)
        }
        
        return AsyncStream { continuation in
            let listener = query.addSnapshotListener { snapshot, error in
                
                if let _ = error {
                    continuation.yield(.error(.readingError))
                }
                else if let snapshot = snapshot {
                    do {
                        let data: [T] = try snapshot.documents.compactMap { document in
                            return try document.data(as: T.self)
                        }
                        continuation.yield(.success(data))
                    }
                    catch {
                        continuation.yield(.error(.decodingError))
                    }
                }
                else {
                    continuation.yield(.error(.documentDoesNotExist))
                }
            }
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    func observeDocument<T: FirestoreDto>(type: T.Type, document: DocumentReference) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>> {
        
        return AsyncStream { continuation in
            let listener = document.addSnapshotListener { snapshot, error in
                
                if let _ = error {
                    continuation.yield(.error(.readingError))
                }
                else if let snapshot = snapshot, snapshot.exists {
                    do {
                        let data = try snapshot.data(as: T.self)
                        continuation.yield(.success(data))
                    }
                    catch {
                        continuation.yield(.error(.decodingError))
                    }
                }
                else {
                    continuation.yield(.error(.documentDoesNotExist))
                }
            }
            continuation.onTermination = { _ in
                listener.remove()
            }
        }
    }
    
    func insertDocument<T: FirestoreDto>(object: T, collection: CollectionReference) async throws {
        let docRef = collection.document()
        try docRef.setData(from: object)
    }
    
    func upsertDocument<T>(object: T, document: DocumentReference) async throws where T : FirestoreDto {
        let _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(document)
                
                if snapshot.exists {
                    
                    // document already exists
                    // check if any changes have occurred and update if necessary
                    var itemToSave = object
                    
                    let existingItem = try snapshot.data(as: T.self)
                    
                    guard !existingItem.contentEquals(object) else {
                        // no update required
                        return true
                    }
                    
                    itemToSave.created = existingItem.created // keep created timestamp
                    itemToSave.modified = nil // update server timestamp
                    
                    try transaction.setData(from: itemToSave, forDocument: document, merge: true)
                    return true
                }
                else {
                    // document does not exist yet -> Insert it
                    try transaction.setData(from: object, forDocument: document)
                    return true
                }
            }
            catch let error as NSError {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
    
    func readDocument<T: FirestoreDto>(document: DocumentReference) async throws -> T {
        return try await document.getDocument(as: T.self)
    }
    
    func deleteDocument(document: DocumentReference) async throws {
        try await document.delete()
    }
    
    func deleteDocuments(documents: [DocumentReference]) async throws {
        let batch = db.batch()
        for document in documents {
            batch.deleteDocument(document)
        }
        try await batch.commit()
    }
}
