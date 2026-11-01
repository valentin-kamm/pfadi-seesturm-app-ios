//
//  CircleProfilePictureView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.04.2025.
//

import SwiftUI
import Kingfisher

struct CircleProfilePictureView: View {
    
    @State private var fullscreenPicture: PhotoSliderViewItem? = nil
    
    private let type: CircleProfilePictureViewType
    private let size: CGFloat
    private let showEditBadge: Bool
    private let tapAction: CircleProfilePictureTapAction?
    
    init(
        type: CircleProfilePictureViewType,
        size: CGFloat,
        showEditBadge: Bool = false,
        tapAction: CircleProfilePictureTapAction?
    ) {
        self.type = type
        self.size = size
        self.showEditBadge = showEditBadge
        self.tapAction = tapAction
    }
    
    var borderColor: Color {
        switch type {
        case .idle(let user):
            return user?.profilePictureUrl == nil ? .secondary : .clear
        case .loading:
            return .secondary
        }
    }
    
    var body: some View {
        ZStack {
            Group {
                switch type {
                case .idle(let u):
                    if let user = u, let imageUrl = user.profilePictureUrl {
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
        .onTapGesture {
            if let action = tapAction {
                switch action {
                case .fullscreenPicture:
                    if case .idle(let u) = type, let user = u {
                        fullscreenPicture = PhotoSliderViewItem(from: user)
                    }
                case .custom(let action):
                    action()
                }
            }
        }
        .fullScreenCover(item: $fullscreenPicture) { item in
            PhotoSliderView(mode: .single(image: item))
        }
    }
}

enum CircleProfilePictureViewType {
    case idle(user: FirebaseHitobitoUser?)
    case loading
}

enum CircleProfilePictureTapAction {
    case fullscreenPicture
    case custom(action: () -> Void)
}

#Preview {
    VStack {
        CircleProfilePictureView(
            type: .idle(user: DummyData.user1),
            size: 60,
            showEditBadge: false,
            tapAction: .fullscreenPicture
        )
        CircleProfilePictureView(
            type: .idle(user: DummyData.user3),
            size: 60,
            showEditBadge: false,
            tapAction: .fullscreenPicture
        )
        CircleProfilePictureView(
            type: .idle(user: DummyData.user3),
            size: 60,
            showEditBadge: true,
            tapAction: .fullscreenPicture
        )
        CircleProfilePictureView(
            type: .loading,
            size: 60,
            showEditBadge: true,
            tapAction: .fullscreenPicture
        )
    }
}
