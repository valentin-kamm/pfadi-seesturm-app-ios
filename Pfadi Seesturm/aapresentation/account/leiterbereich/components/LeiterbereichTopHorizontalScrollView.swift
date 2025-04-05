//
//  LeiterbereichTopHorizontalScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI

struct LeiterbereichTopHorizontalScrollView<F: NavigationDestination>: View {
    
    let foodState: UiState<[FoodOrder]>
    let foodNavigationDestination: F
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                NavigationLink(value: foodNavigationDestination) {
                    CustomCardView {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "fork.knife")
                                .foregroundStyle(Color.SEESTURM_RED)
                            VStack(alignment: .leading) {
                                Text("Essen bestellen")
                                    .fontWeight(.bold)
                                    .font(.caption)
                                    .lineLimit(1)
                                switch foodState {
                                case .loading(_):
                                    Text("0 Bestellungen")
                                        .font(.caption)
                                        .redacted(reason: .placeholder)
                                        .customLoadingBlinking()
                                case .error(_):
                                    Image(systemName: "exclamationmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(Color.SEESTURM_RED)
                                        .frame(width: 15, height: 15)
                                case .success(let data):
                                    let sum = data.map { $0.totalCount }.reduce(0, +)
                                    Text("\(sum) " + (sum == 1 ? "Bestellung" : "Bestellungen"))
                                        .font(.caption)
                                        .lineLimit(1)
                                }
                            }
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(8)
                    }
                    .foregroundStyle(Color.primary)
                }
                .padding(.leading)
            }
            .padding(.vertical)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    LeiterbereichTopHorizontalScrollView(
        foodState: .success(data: [FoodOrder(
            id: "",
            itemDescription: "",
            totalCount: 12,
            userIds: [],
            users: [],
            ordersString: "XXX"
        )
        ]),
        foodNavigationDestination: AccountNavigationDestination.food(
            user: FirebaseHitobitoUser(
                userId: "",
                vorname: "",
                nachname: "",
                pfadiname: "",
                email: "",
                created: Date(),
                createdFormatted: "",
                modified: Date(),
                modifiedFormatted: ""
            )
        )
    )
}
