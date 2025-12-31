//
//  FirestoreApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import Foundation
import FirebaseFirestore

protocol FirestoreApi {
        
    func insertDocument<T: FirestoreDto>(object: T, collection: CollectionReference) async throws
    func upsertDocument<T: FirestoreDto>(object: T, document: DocumentReference) async throws
    func readDocument<T: FirestoreDto>(document: DocumentReference) async throws -> T
    func readCollection<T: FirestoreDto>(collection: CollectionReference, filter: ((Query) -> Query)?) async throws -> [T]
    func deleteDocument(document: DocumentReference) async throws
    func deleteDocuments(documents: [DocumentReference]) async throws
    func deleteAllDocuments(in collection: CollectionReference) async throws
    func observeDocument<T: FirestoreDto>(type: T.Type, document: DocumentReference) -> AsyncStream<SeesturmResult<T, RemoteDatabaseError>>
    func observeCollection<T: FirestoreDto>(
        type: T.Type,
        collection: CollectionReference,
        filter: ((Query) -> Query)?
    ) -> AsyncStream<SeesturmResult<[T], RemoteDatabaseError>>
    func performTransaction<T: FirestoreDto>(type: T.Type, document: DocumentReference, forceNewCreatedDate: Bool, update: @escaping (T) throws -> T) async throws
}

class FirestoreApiImpl: FirestoreApi {
    
    private let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func insertDocument<T: FirestoreDto>(object: T, collection: CollectionReference) async throws {
        
        let docRef = collection.document()
        try docRef.setData(from: object)
    }
    
    func upsertDocument<T>(object: T, document: DocumentReference) async throws where T : FirestoreDto {
        let _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(document)
                
                guard snapshot.exists else {
                    // document does not exist yet -> insert it
                    try transaction.setData(from: object, forDocument: document)
                    return true
                }
                
                let existingItem = try snapshot.data(as: T.self)
                
                guard !existingItem.contentEquals(object) else {
                    // data has not changed -> do nothing
                    return true
                }
                
                // document exists and data has changed -> perform update with merge, set timestamps correctly
                var itemToSave = object
                itemToSave.created = existingItem.created
                itemToSave.modified = nil
                
                try transaction.setData(from: itemToSave, forDocument: document, merge: true)
                
                return true
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
    
    func readCollection<T: FirestoreDto>(collection: CollectionReference, filter: ((Query) -> Query)?) async throws -> [T] {
        
        var query: Query = collection
        if let f = filter {
            query = f(query)
        }
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
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
    
    func deleteAllDocuments(in collection: CollectionReference) async throws {
        
        let documents = try await collection.getDocuments().documents.map { $0.reference }
        try await deleteDocuments(documents: documents)
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
    
    func performTransaction<T: FirestoreDto>(
        type: T.Type,
        document: DocumentReference,
        forceNewCreatedDate: Bool,
        update: @escaping (T) throws -> T
    ) async throws {
        
        let _ = try await db.runTransaction { transaction, errorPointer in
            do {
                let snapshot = try transaction.getDocument(document)
                let currentData = try snapshot.data(as: T.self)
                var newData = try update(currentData)
                
                if forceNewCreatedDate {
                    newData.created = nil
                    newData.modified = nil
                    
                    try transaction.setData(from: newData, forDocument: document)
                    return true
                }
                else if currentData.contentEquals(newData) {
                    return true
                }
                else {
                    newData.created = currentData.created
                    newData.modified = nil
                    
                    try transaction.setData(from: newData, forDocument: document)
                    return true
                }
            }
            catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        }
    }
}
