//
//  LeitungsteamCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.10.2024.
//

import SwiftUI
import Kingfisher

struct LeitungsteamCell: View {
    
    private let member: LeitungsteamMember
    private let imageSize: CGFloat
    
    init(
        member: LeitungsteamMember,
        imageSize: CGFloat = 130
    ) {
        self.member = member
        self.imageSize = imageSize
    }
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            HStack(spacing: 16) {
                if let imageUrl = URL(string: member.photo) {
                    KFImage(imageUrl)
                        .placeholder { progress in
                            Color.skeletonPlaceholderColor
                                .frame(width: imageSize, height: imageSize)
                                .loadingBlinking()
                        }
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipped()
                }
                else {
                    Rectangle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(width: imageSize, height: imageSize)
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
                .frame(maxWidth: .infinity, maxHeight: imageSize, alignment: .leading)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    LeitungsteamCell(
        member: DummyData.leitungsteamMember
    )
}
