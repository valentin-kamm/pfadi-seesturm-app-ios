//
//  FoodOrderDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI
import FirebaseFirestore

struct FoodOrderDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    var itemDescription: String
    var userIds: [String]
    
    func contentEquals(_ other: FoodOrderDto) -> Bool {
        return id == other.id &&
        itemDescription == other.itemDescription &&
        userIds == other.userIds
    }
}

extension FoodOrderDto {
    func toFoodOrder(users: [FirebaseHitobitoUser]) -> FoodOrder {
        return FoodOrder(
            id: id ?? UUID().uuidString,
            itemDescription: itemDescription,
            totalCount: userIds.count,
            userIds: userIds,
            users: users.getUsersById(uids: userIds),
            ordersString: constructOrdersString(userIds: userIds, users: users)
        )
    }
    private func constructOrdersString(userIds: [String], users: [FirebaseHitobitoUser]) -> String {
        let userNames = users.getUsersById(uids: userIds).map { $0?.displayNameShort ?? "Unbekannt" }
        var nameCount: [String: Int] = [:]
        for name in userNames {
            nameCount[name, default: 0] += 1
        }
        return nameCount.map { "\($0.key) (\($0.value)\u{00D7})" }.joined(separator: ", ")
    }
}
