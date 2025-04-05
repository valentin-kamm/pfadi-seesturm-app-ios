//
//  FirestoreManager.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.12.2024.
//
import Foundation
import FirebaseFirestore

class FirestoreManager {
    
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    // structure of my database
    struct FirestoreStructure {
        struct FirestoreUserCollection {
            static let collectionPath = "users"
            static let collection = FirestoreManager.shared.db.collection(collectionPath)
        }
        struct FirestoreLeiterbereichCollection {
            static let collectionPath = "leiterbereich"
            static let collection = FirestoreManager.shared.db.collection(collectionPath)
            struct FirestoreSchopflialarmDocument {
                static let documentPath = "schopflialarm"
                static let document = collection.document(documentPath)
            }
            struct FirestoreFoodDocument {
                static let documentPath = "food"
                static let document = collection.document(documentPath)
                struct FirestoreOrdersCollection {
                    static let collectionPath = "orders"
                    static let collection = document.collection(collectionPath)
                }
            }
        }
        struct FirestoreAbmeldungenCollection {
            static let collectionPath = "abmeldungen"
            static let collection = FirestoreManager.shared.db.collection(collectionPath)
        }
    }
    
    // function to perform a transaction on any document
    func performTransaction<T: Codable>(
        documentReference: DocumentReference,
        as type: T.Type,
        transactionLogic: @escaping (T) throws -> T
    ) async throws {
        do {
            let _ = try await db.runTransaction { transaction, errorPointer in
                do {
                    let snapshot = try transaction.getDocument(documentReference)
                    guard snapshot.exists else {
                        throw PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Der Datensatz existiert nicht.")
                    }
                    let jsonData = try snapshot.data(as: T.self, with: .estimate)
                    let updatedObject = try transactionLogic(jsonData)
                    transaction.setData(try Firestore.Encoder().encode(updatedObject), forDocument: documentReference)
                    return nil
                }
                catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }
        }
        catch {
            if let pfadiSeesturmError = error as? PfadiSeesturmAppError {
                throw pfadiSeesturmError
            }
            throw error
        }
        
    }
    
    // function to get live updates on a firestore collection
    func observeCollection<T: Decodable>(
        collectionReference: CollectionReference,
        as type: T.Type
    ) -> AsyncThrowingStream<[T], Error> {
        AsyncThrowingStream { continuation in
            let listener = collectionReference.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Datensätze konnten nicht geladen werden: \(error.localizedDescription)"))
                    return
                }
                guard let snapshot = snapshot else {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Datensätze konnten nicht geladen werden, da der Server keine Daten geliefert hat."))
                    return
                }
                if snapshot.isEmpty {
                    continuation.yield([])
                    return
                }
                do {
                    let decodedObjects: [T] = try snapshot.documents.compactMap { document in
                        let data: T = try document.data(as: T.self, with: .estimate)
                        return try self.includeDocumentIdIfNecessary(data: data, documentId: document.documentID)
                    }
                    continuation.yield(decodedObjects)
                    return
                }
                catch {
                    if let pfadiSeesturmError = error as? PfadiSeesturmAppError {
                        continuation.finish(throwing: pfadiSeesturmError)
                    }
                    else {
                        continuation.finish(throwing: error)
                    }
                    return
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // function to get live updates on a single firestore document
    func observeSingleDocument<T: Decodable>(
        documentReference: DocumentReference,
        as type: T.Type
    ) -> AsyncThrowingStream<T?, Error> {
        AsyncThrowingStream { continuation in
            let listener = documentReference.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Ein Datensatz konnte nicht geladen werden: \(error.localizedDescription)"))
                    return
                }
                guard let snapshot = snapshot else {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidResponse(message: "Ein Datensatz konnte nicht geladen werden, da der Server keine Daten geliefert hat."))
                    return
                }
                if !snapshot.exists {
                    continuation.yield(nil)
                    return
                }
                do {
                    let decodedObject = try snapshot.data(as: T.self, with: .estimate)
                    let transformedDecodedObject = try self.includeDocumentIdIfNecessary(data: decodedObject, documentId: snapshot.documentID)
                    continuation.yield(transformedDecodedObject)
                    return
                }
                catch {
                    continuation.finish(throwing: PfadiSeesturmAppError.invalidData(message: "Ein Datensatz konnte nicht geladen werden, da die übermittelten Daten fehlerhaft sind."))
                    return
                }
            }
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // function to read an entire collection from firebase
    func readCollection<T: Decodable>(
        collectionReference: CollectionReference,
        as type: T.Type,
        filter: ((Query) -> Query)? = nil
    ) async throws -> [T] {
        var query: Query = collectionReference
        if let f = filter {
            query = f(query)
        }
        let snapshot = try await query.getDocuments()
        guard !snapshot.isEmpty else {
            throw PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Kein Datensatz vorhanden.")
        }
        do {
            return try snapshot.documents.compactMap { document in
                let data: T = try document.data(as: T.self, with: .estimate)
                return try includeDocumentIdIfNecessary(data: data, documentId: document.documentID)
            }
        }
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Datensätze konnten nicht gelesen werden. Die Daten sind ungültig.")
        }
    }
    
    // function to read a single document from firestore and parse it
    func readSingleDocument<T: Decodable>(
        documentReference: DocumentReference,
        as type: T.Type
    ) async throws -> T {
        let document = try await documentReference.getDocument()
        guard document.exists else {
            throw PfadiSeesturmAppError.firestoreDocumentDoesNotExistError(message: "Der Datensatz existiert nicht.")
        }
        do {
            let data = try document.data(as: T.self, with: .estimate)
            return try includeDocumentIdIfNecessary(data: data, documentId: document.documentID)
        }
        catch {
            throw PfadiSeesturmAppError.invalidData(message: "Ein Datensatz konnte nicht gelesen werden. Die Daten sind ungültig.")
        }
    }
    
    // function to save any data to any collection
    func setNewFirestoreDocument<T: Codable>(
        object: T,
        toCollection: CollectionReference
    ) async throws {
        let documentReference = toCollection.document()
        try await documentReference.setData(try Firestore.Encoder().encode(object))
    }
    func updateFirestoreDocument<T: Codable>(
        object: T,
        documentReference: DocumentReference
    ) async throws {
        try await documentReference.setData(try Firestore.Encoder().encode(object))
    }
    
    // function that deletes documents from a collection
    func deleteDocuments(
        from collectionReference: CollectionReference,
        documentIds: [String]
    ) async throws {
        guard !documentIds.isEmpty else {
            return
        }
        let batch = db.batch()
        for documentId in documentIds {
            let docRef = collectionReference.document(documentId)
            batch.deleteDocument(docRef)
        }
        try await batch.commit()
    }
    
    // function to convert a firebase timestamp to a date
    func convertFirestoreTimestampToDate(timestamp: Timestamp?) throws -> Date {
        if let ts = timestamp {
            return ts.dateValue()
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datum nicht vorhanden.")
        }
    }
    
    // function that includes the firestore document id in a object if desired
    private func includeDocumentIdIfNecessary<T: Decodable>(
        data: T,
        documentId: String
    ) throws -> T {
        if var obj = data as? StructWithIdField {
            obj.firestoreDocumentId = documentId
            guard let finObj = obj as? T else {
                throw PfadiSeesturmAppError.invalidData(message: "Ein Datensatz konnte nicht gelesen werden. Die Daten sind ungültig.")
            }
            return finObj
        }
        else {
            return data
        }
    }
    
    // function that converts two variables of type SeesturmLoadingState into one
    func combineTwoLoadingStates<T1, T2, R>(
        state1: SeesturmLoadingState<T1, PfadiSeesturmAppError>,
        state2: SeesturmLoadingState<T2, PfadiSeesturmAppError>,
        transform: (T1, T2) throws -> R
    ) -> SeesturmLoadingState<R, PfadiSeesturmAppError> {
        switch (state1, state2) {
        case (.none, .none):
            return .none
        case (.none, .loading):
            return .loading
        case (.none, .result(.failure(let error))):
            return .result(.failure(error))
        case (.none, .result(.success(_))):
            return .loading
        case (.none, .errorWithReload(_)):
            return .none

        case (.loading, .none):
            return .loading
        case (.loading, .loading):
            return .loading
        case (.loading, .result(.failure(let error))):
            return .result(.failure(error))
        case (.loading, .result(.success(_))):
            return .loading
        case (.loading, .errorWithReload(_)):
            return .loading

        case (.result(.failure(let error1)), .none):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .loading):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .result(.failure(_))):
            return .result(.failure(error1))
        case (.result(.failure(let error1)), .result(.success(_))):
            return .result(.failure(error1))
        case (.result(.failure(_)), .errorWithReload(_)):
            return .none
            
        case (.result(.success(_)), .none):
            return .loading
        case (.result(.success(_)), .loading):
            return .loading
        case (.result(.success(_)), .result(.failure(let error2))):
            return .result(.failure(error2))
        case (.result(.success(let data1)), .result(.success(let data2))):
            do {
                return .result(.success(try transform(data1, data2)))
            }
            catch {
                return .result(.failure(PfadiSeesturmAppError.invalidData(message: "Die vom Server übermittelten Daten sind ungültig.")))
            }
        case (.result(.success(_)), .errorWithReload(_)):
            return .none

        case (.errorWithReload(_), .none):
            return .none
        case (.errorWithReload(_), .loading):
            return .loading
        case (.errorWithReload(_), .result(.failure(_))):
            return .none
        case (.errorWithReload(_), .result(.success(_))):
            return .none
        case (.errorWithReload(_), .errorWithReload(_)):
            return .none
        }
    }
    
}
