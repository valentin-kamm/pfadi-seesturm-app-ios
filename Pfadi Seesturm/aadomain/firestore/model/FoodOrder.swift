//
//  FoodOrder.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//

struct FoodOrder {
    var id: String
    var itemDescription: String
    var totalCount: Int
    var userIds: [String]
    var users: [FirebaseHitobitoUser?]
    var ordersString: String
}
