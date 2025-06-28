//
//  CircleProfilePictureView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.04.2025.
//

import SwiftUI
import Kingfisher

struct CircleProfilePictureView: View {
    
    private let user: FirebaseHitobitoUser?
    private let size: CGFloat
    private let isLoading: Bool
    private let showEditBadge: Bool
    
    init(
        user: FirebaseHitobitoUser?,
        size: CGFloat,
        isLoading: Bool = false,
        showEditBadge: Bool = false
    ) {
        self.user = user
        self.size = size
        self.isLoading = isLoading
        self.showEditBadge = showEditBadge
    }
    
    var borderColor: Color {
        if isLoading || user?.profilePictureUrl == nil {
            return .secondary
        }
        return .clear
    }
    
    var body: some View {
        ZStack {
            Group {
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
                        .renderingMode(isLoading ? Image.TemplateRenderingMode.template : Image.TemplateRenderingMode.original)
                }
                else {
                    Image("SeesturmLogo")
                        .renderingMode(isLoading ? Image.TemplateRenderingMode.template : Image.TemplateRenderingMode.original)
                        .resizable()
                        .padding(3)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .scaledToFill()
            .frame(width: size, height: size)
            .clipped()
            .foregroundStyle(isLoading ? Color.clear : Color.SEESTURM_GREEN)
            
            if isLoading {
                ProgressView()
                    .tint(Color.SEESTURM_GREEN)
                    .id(UUID())
            }
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

#Preview {
    VStack {
        CircleProfilePictureView(
            user: DummyData.user1,
            size: 60,
            isLoading: false,
            showEditBadge: false
        )
        CircleProfilePictureView(
            user: DummyData.user3,
            size: 60,
            isLoading: false,
            showEditBadge: false
        )
        CircleProfilePictureView(
            user: DummyData.user3,
            size: 60,
            isLoading: false,
            showEditBadge: true
        )
        CircleProfilePictureView(
            user: DummyData.user3,
            size: 60,
            isLoading: true,
            showEditBadge: true
        )
    }
}
