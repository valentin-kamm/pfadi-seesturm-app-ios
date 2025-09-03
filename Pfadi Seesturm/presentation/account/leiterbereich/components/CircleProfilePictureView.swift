//
//  CircleProfilePictureView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.04.2025.
//

import SwiftUI
import Kingfisher

struct CircleProfilePictureView: View {
    
    private let type: ProfilePictureType
    private let size: CGFloat
    private let showEditBadge: Bool
    
    init(
        type: ProfilePictureType,
        size: CGFloat,
        showEditBadge: Bool = false
    ) {
        self.type = type
        self.size = size
        self.showEditBadge = showEditBadge
    }
    
    var borderColor: Color {
        
        switch type {
        case .user(let user):
            return user?.profilePictureUrl == nil ? .secondary : .clear
        case .loading:
            return .secondary
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                switch type {
                case .user(let user):
                    if let imageUrl = user?.profilePictureUrl {
                        KFImage(imageUrl)
                            .placeholder {
                                Rectangle()
                                    .fill(Color.skeletonPlaceholderColor)
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: size, height: size)
                                    .loadingBlinking()
                                    .clipped()
                            }
                            .resizable()
                    }
                    else {
                        Image("SeesturmLogo")
                            .resizable()
                            .padding(0.05 * size)
                    }
                case .loading:
                    ZStack {
                        Rectangle()
                            .fill(Color.customCardViewBackground)
                        SeesturmProgressView(
                            color: Color.SEESTURM_GREEN
                        )
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
        }
        .frame(width: size, height: size)
        .background(Color.customCardViewBackground)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: 1)
        )
        .overlay {
            if showEditBadge {
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(Color.white)
                    .background(
                        Circle()
                            .fill(Color.SEESTURM_GREEN)
                            .frame(width: 22, height: 22)
                    )
                    .offset(x: size / 2.5, y: size / 2.5)
            }
        }
    }
}

enum ProfilePictureType {
    case user(user: FirebaseHitobitoUser?)
    case loading
}

#Preview {
    VStack {
        CircleProfilePictureView(
            type: .user(user: DummyData.user1),
            size: 60,
            showEditBadge: false
        )
        CircleProfilePictureView(
            type: .user(user: DummyData.user3),
            size: 60,
            showEditBadge: false
        )
        CircleProfilePictureView(
            type: .user(user: DummyData.user3),
            size: 60,
            showEditBadge: true
        )
        CircleProfilePictureView(
            type: .loading,
            size: 60,
            showEditBadge: false
        )
        CircleProfilePictureView(
            type: .loading,
            size: 60,
            showEditBadge: true
        )
    }
}
