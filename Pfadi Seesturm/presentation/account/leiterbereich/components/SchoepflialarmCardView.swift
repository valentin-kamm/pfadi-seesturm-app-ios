//
//  SchoepflialarmCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.04.2025.
//

import SwiftUI

struct SchoepflialarmCardView: View {
    
    private let schoepflialarm: Schoepflialarm
    private let user: FirebaseHitobitoUser
    private let onClick: () -> Void
    
    init(
        schoepflialarm: Schoepflialarm,
        user: FirebaseHitobitoUser,
        onClick: @escaping () -> Void
    ) {
        self.schoepflialarm = schoepflialarm
        self.user = user
        self.onClick = onClick
    }
    
    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 16) {
                    CircleProfilePictureView(
                        type: .idle(user: schoepflialarm.user),
                        size: 30
                    )
                    Text(schoepflialarm.user?.displayNameShort ?? "Unbekannter Benutzer")
                        .font(.callout)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .layoutPriority(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(schoepflialarm.createdFormatted)
                        .font(.caption)
                        .lineLimit(2)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Color.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text(schoepflialarm.message)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .center, spacing: 8) {
                    ForEach(SchoepflialarmReactionType.allCases.sorted { $0.sortingOrder < $1.sortingOrder }) { reaction in
                        CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                            Label(title: {
                                Text("\(schoepflialarm.reactionCount(for: reaction))")
                                    .font(.callout)
                                    .lineLimit(1)
                            }, icon: {
                                Image(systemName: reaction.systemImageName)
                                    .foregroundStyle(reaction.color)
                            })
                            .padding(8)
                            .labelStyle(.titleAndIcon)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .onTapGesture {
            onClick()
        }
    }
}

#Preview {
    SchoepflialarmCardView(
        schoepflialarm: DummyData.schoepflialarm,
        user: DummyData.user1,
        onClick: {}
    )
    .padding()
}
