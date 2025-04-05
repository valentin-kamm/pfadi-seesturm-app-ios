//
//  LeiterbereichService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//

class LeiterbereichService: WordpressService {
    
    private let termineRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    
    init(
        termineRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository
    ) {
        self.termineRepository = termineRepository
        self.firestoreRepository = firestoreRepository
    }
    
    func getNext3Events(calendar: SeesturmCalendar) async -> SeesturmResult<GoogleCalendarEvents, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.termineRepository.getNext3Events(calendar: calendar) },
            transform: { try $0.toGoogleCalendarEvents() }
        )
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
            try await firestoreRepository.deleteDocuments(documents: orders.map { .order(id: $0.id) })
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
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
                let users = try d.map { try $0.toFirebaseHitobitoUser() }
                return .success(users)
            }
            catch {
                return .error(.decodingError)
            }
        }
    }
}

// to transform async streams similar to kotlin flows
extension AsyncStream {
    func map<Transformed>(
        _ transform: @escaping (Element) -> Transformed
    ) -> AsyncStream<Transformed> {
        var iterator = self.makeAsyncIterator()
        return AsyncStream<Transformed> {
            guard let value = await iterator.next() else { return nil }
            return transform(value)
        }
    }
}
