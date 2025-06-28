//
//  StufenbereichAnAbmeldungenLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungLoadingCell: View {
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Circle()
                        .fill(Color.skeletonPlaceholderColor)
                        .frame(width: 40, height: 40)
                        .loadingBlinking()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Label("Abmeldungen", systemImage: AktivitaetInteractionType.abmelden.icon)
                    .font(.caption)
                    .opacity(0)
                    .lineLimit(1)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.skeletonPlaceholderColor)
                    )
                    .labelStyle(.titleAndIcon)
                    .loadingBlinking()
                Rectangle()
                    .fill(Color.skeletonPlaceholderColor)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .cornerRadius(16)
                    .loadingBlinking()
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    StufenbereichAnAbmeldungLoadingCell()
}
