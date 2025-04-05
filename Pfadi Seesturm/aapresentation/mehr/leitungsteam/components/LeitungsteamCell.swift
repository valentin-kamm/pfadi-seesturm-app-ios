//
//  LeitungsteamCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//

import SwiftUI
import Kingfisher

struct LeitungsteamCell: View {
    
    var member: LeitungsteamMember
    var dimension: CGFloat = 130
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            HStack(spacing: 16) {
                if let imageUrl = URL(string: member.photo) {
                    KFImage(imageUrl)
                        .placeholder { progress in
                            Color.skeletonPlaceholderColor
                                .frame(width: dimension, height: dimension)
                                .customLoadingBlinking()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: dimension, height: dimension)
                        .clipped()
                }
                else {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(width: dimension, height: dimension)
                        .overlay {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                        }
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(member.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fontWeight(.bold)
                        .font(.callout)
                        .allowsTightening(true)
                        .lineLimit(2)
                    Text(member.job)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.caption)
                        .allowsTightening(true)
                        .lineLimit(1)
                    if (member.contact != "") {
                        Label(member.contact, systemImage: "envelope")
                            .lineLimit(1)
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .allowsTightening(true)
                    }
                    Spacer(minLength: 0)
                }
                .padding([.vertical, .trailing])
                .frame(maxWidth: .infinity, maxHeight: dimension, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LeitungsteamCell(
        member: LeitungsteamMember(
            id: UUID(),
            name: "Test name / Pfadiname Pfadiname",
            job: "Stufenleitung Pfadistufe",
            contact: "xxx@yyy.ch",
            photo: "https://seesturm.ch/wp-content/uploads/2017/10/Wicky2021-scaled.jpg"
        )
    )
}
