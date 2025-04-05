//
//  LeiterbereichProfileHeaderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 24.03.2025.
//
import SwiftUI

struct LeiterbereichProfileHeaderView: View {
    
    let user: FirebaseHitobitoUser
    let isLoading: Bool
    let onSignOut: () -> Void
    let onDeleteAccount: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
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
                        Text("Account löschen")
                        Image(systemName: "person.crop.circle.badge.xmark")
                    }
                }
            } label: {
                ZStack {
                    Image("SeesturmLogo")
                        .renderingMode(isLoading ? Image.TemplateRenderingMode.template : Image.TemplateRenderingMode.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(2)
                        .foregroundStyle(isLoading ? Color.clear : Color.SEESTURM_GREEN)
                    if isLoading {
                        ProgressView()
                            .tint(Color.SEESTURM_GREEN)
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color.customCardViewBackground)
                .clipShape(Circle())
            }
            .padding(.bottom, 4)
            .disabled(isLoading)
            Text("Willkommen, \(user.displayNameShort)!")
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .fontWeight(.bold)
                .font(.footnote)
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
