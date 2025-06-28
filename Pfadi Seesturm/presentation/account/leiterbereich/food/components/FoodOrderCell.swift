//
//  FoodOrderCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//

import SwiftUI

struct FoodOrderCell: View {
    
    private let order: FoodOrder
    private let user: FirebaseHitobitoUser
    private let onDelete: () async -> Void
    private let onAdd: () async -> Void
    
    init(
        order: FoodOrder,
        user: FirebaseHitobitoUser,
        onDelete: @escaping () async -> Void,
        onAdd: @escaping () async -> Void
    ) {
        self.order = order
        self.user = user
        self.onDelete = onDelete
        self.onAdd = onAdd
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("\(order.totalCount)\u{00D7}")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.SEESTURM_GREEN)
                .lineLimit(1)
                .allowsTightening(true)
            VStack(alignment: .trailing, spacing: 8) {
                Text(order.itemDescription)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .fontWeight(.bold)
                    .font(.callout)
                Text(order.ordersString)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            HStack(alignment: .center, spacing: 16) {
                if order.userIds.contains(user.userId) {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color.SEESTURM_RED)
                            .frame(width: 25, height: 25)
                        Image(systemName: "minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 25)
                    .onTapGesture {
                        Task {
                            await onDelete()
                        }
                    }
                }
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Color.SEESTURM_GREEN)
                        .frame(width: 25, height: 25)
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.white)
                }
                .frame(width: 25)
                .onTapGesture {
                    Task {
                        await onAdd()
                    }
                }
            }
            .frame(width: 66, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Contains user") {
    FoodOrderCell(
        order: DummyData.foodOrders[0],
        user: DummyData.user1,
        onDelete: {},
        onAdd: {}
    )
}
#Preview("Does not contain user") {
    FoodOrderCell(
        order: DummyData.foodOrders[2],
        user: DummyData.user1,
        onDelete: {},
        onAdd: {}
    )
}
