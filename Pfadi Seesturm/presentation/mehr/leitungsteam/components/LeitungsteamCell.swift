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
        imageSize: CGFloat = 115
    ) {
        self.member = member
        self.imageSize = imageSize
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 16) {
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
                    .clipShape(Circle())
            }
            else {
                Circle()
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
            VStack(alignment: .leading, spacing: 16) {
                Text(member.name)
                    .multilineTextAlignment(.leading)
                    .fontWeight(.bold)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(member.job)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let email = member.contact.toEmail, let url = URL(string: "mailto:\(email)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                    SeesturmButton(
                        type: .secondary,
                        action: .sync(action: {
                            UIApplication.shared.open(url)
                        }),
                        title: email,
                        icon: SeesturmButtonIconType.system(name: "envelope"),
                        colors: SeesturmButtonColor.custom(
                            contentColor: .white,
                            buttonColor: .SEESTURM_GREEN
                        )
                    )
                }
                else if !member.contact.isEmpty {
                    Label(member.contact, systemImage: "envelope")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    LeitungsteamCell(
        member: DummyData.leitungsteamMember
    )
}
