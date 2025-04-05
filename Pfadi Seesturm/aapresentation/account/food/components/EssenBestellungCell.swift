//
//  EssenBestellungCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//

import SwiftUI

struct EssenBestellungCell: View {
    
    let order: FoodOrder
    let user: FirebaseHitobitoUser
    let onDeleteButtonClick: () -> Void
    let onAddButtonClick: () -> Void
    
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
                        onDeleteButtonClick()
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
                    onAddButtonClick()
                }
            }
            .frame(width: 66, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    EssenBestellungCell(
        order: FoodOrder(
            id: "123",
            itemDescription: "Burger",
            totalCount: 5,
            userIds: ["123", "123", "1234", "1234", "12313"],
            users: [],
            ordersString: "Sepp (2x), Maja (3x)"
        ),
        user: FirebaseHitobitoUser(
            userId: "12313",
            vorname: "Sepp",
            nachname: "Müller",
            pfadiname: nil,
            email: "Test@test.test",
            created: Date(),
            createdFormatted: "",
            modified: Date(),
            modifiedFormatted: ""
        ),
        onDeleteButtonClick: {},
        onAddButtonClick: {}
    )
}
