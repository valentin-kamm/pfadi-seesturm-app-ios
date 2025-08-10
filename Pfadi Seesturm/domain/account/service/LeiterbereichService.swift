//
//  LeiterbereichService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI
import PhotosUI

class LeiterbereichService: WordpressService {
    
    private let termineRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    private let storageRepository: StorageRepository
    
    init(
        termineRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository,
        storageRepository: StorageRepository
    ) {
        self.termineRepository = termineRepository
        self.firestoreRepository = firestoreRepository
        self.storageRepository = storageRepository
    }
    
    func fetchNext3Events(calendar: SeesturmCalendar) async -> SeesturmResult<[GoogleCalendarEvent], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.termineRepository.getNextThreeEvents(calendar: calendar) },
            transform: { try $0.toGoogleCalendarEvents().items }
        )
    }
    
    func observeFoodOrders() -> AsyncStream<SeesturmResult<[FoodOrderDto], RemoteDatabaseError>> {
        return firestoreRepository.observeCollection(type: FoodOrderDto.self, collection: .foodOrders, filter: nil)
    }
    
    func observeUsers() -> AsyncStream<SeesturmResult<[FirebaseHitobitoUser], RemoteDatabaseError>> {
        return firestoreRepository.observeCollection(type: FirebaseHitobitoUserDto.self, collection: .users, filter: nil).map(transformUserStream)
    }
    private func transformUserStream(_ input: SeesturmResult<[FirebaseHitobitoUserDto], RemoteDatabaseError>) -> SeesturmResult<[FirebaseHitobitoUser], RemoteDatabaseError> {
        switch input {
        case .error(let e):
            return .error(e)
        case .success(let d):
            do {
                let users = try d.map { try FirebaseHitobitoUser($0) }
                return .success(users)
            }
            catch {
                return .error(.decodingError)
            }
        }
    }
    
    func addNewFoodOrder(order: FoodOrderDto) async -> SeesturmResult<Void, RemoteDatabaseError> {
        do {
            try await firestoreRepository.insertDocument(
                object: order,
                collection: .foodOrders
            )
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
    func deleteFromExistingOrder(userId: String, orderId: String) async -> SeesturmResult<Void, RemoteDatabaseError> {
        do {
            try await firestoreRepository.performTransaction(
                type: FoodOrderDto.self,
                document: .order(id: orderId),
                forceNewCreatedDate: false,
                update: { oldOrder in
                    if let firstIndex = oldOrder.userIds.firstIndex(of: userId) {
                        var newUserList = oldOrder.userIds
                        newUserList.remove(at: firstIndex)
                        return FoodOrderDto(
                            id: oldOrder.id,
                            created: oldOrder.created,
                            modified: nil,
                            itemDescription: oldOrder.itemDescription,
                            userIds: newUserList
                        )
                    }
                    else {
                        return oldOrder
                    }
                }
            )
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    func addToExistingOrder(userId: String, orderId: String) async -> SeesturmResult<Void, RemoteDatabaseError> {
        do {
            try await firestoreRepository.performTransaction(
                type: FoodOrderDto.self,
                document: .order(id: orderId),
                forceNewCreatedDate: false,
                update: { oldOrder in
                    var newUserList = oldOrder.userIds
                    newUserList.append(userId)
                    return FoodOrderDto(
                        id: oldOrder.id,
                        created: oldOrder.created,
                        modified: nil,
                        itemDescription: oldOrder.itemDescription,
                        userIds: newUserList
                    )
                }
            )
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    func deleteAllOrders(orders: [FoodOrder]) async -> SeesturmResult<Void, RemoteDatabaseError> {
        do {
            let documents = orders.map { SeesturmFirestoreDocument.order(id: $0.id) }
            try await firestoreRepository.deleteDocuments(documents: documents)
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    
    func uploadProfilePicture(item: PhotosPickerItem, user: FirebaseHitobitoUser) -> AsyncStream<ProgressActionState<Void>> {
        AsyncStream { continuation in
            Task {
                do {
                    let downloadUrl = try await storageRepository.uploadData(
                        item: .profilePicture(user: user, item: item),
                        metadata: nil
                    ) { progress in
                        continuation.yield(.loading(action: (), progress: progress))
                    }
                    try await firestoreRepository.performTransaction(
                        type: FirebaseHitobitoUserDto.self,
                        document: .user(id: user.userId),
                        forceNewCreatedDate: false
                    ) { oldUser in
                        FirebaseHitobitoUserDto(from: oldUser, newProfilePictureUrl: downloadUrl.absoluteString)
                    }
                    continuation.yield(.success(action: (), message: "Das Profilbild wurde erfolgreich gespeichert."))
                }
                catch {
                    let message: String
                    if let pfadiSeesturmError = error as? PfadiSeesturmError {
                        message = pfadiSeesturmError.localizedDescription
                    }
                    else {
                        message = "Beim Hochladen der Daten ist ein unbekannter Fehler aufgetreten."
                    }
                    continuation.yield(.error(action: (), message: message))
                }
                continuation.finish()
            }
        }
    }
}
