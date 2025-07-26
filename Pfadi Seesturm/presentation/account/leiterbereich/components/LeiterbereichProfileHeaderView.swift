//
//  LeiterbereichProfileHeaderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI

struct LeiterbereichProfileHeaderView: View {
    
    private let user: FirebaseHitobitoUser
    private let isLoading: Bool
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    
    init(
        user: FirebaseHitobitoUser,
        isLoading: Bool,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void
    ) {
        self.user = user
        self.isLoading = isLoading
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Menu {
                Button {
                    onSignOut()
                } label: {
                    HStack {
                        Text("Abmelden")
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                    }
                }
                Button {
                    onDeleteAccount()
                } label: {
                    HStack {
                        Text("App-Account löschen")
                        Image(systemName: "person.crop.circle.badge.xmark")
                    }
                }
            } label: {
                CircleProfilePictureView(
                    user: user,
                    size: 40,
                    isLoading: isLoading,
                    showEditBadge: true
                )
            }
            .padding(.bottom, 4)
            .disabled(isLoading)
            Text("Willkommen, \(user.displayNameShort)!")
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .font(.callout)
                .lineLimit(2)
            if let em = user.email {
                Text(em)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    VStack {
        LeiterbereichProfileHeaderView(
            user: DummyData.user3,
            isLoading: false,
            onSignOut: {},
            onDeleteAccount: {}
        )
        LeiterbereichProfileHeaderView(
            user: DummyData.user1,
            isLoading: true,
            onSignOut: {},
            onDeleteAccount: {}
        )
    }
}
