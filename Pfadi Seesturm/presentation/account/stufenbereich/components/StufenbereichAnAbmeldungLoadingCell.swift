//
//  StufenbereichAnAbmeldungenLoadingCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungLoadingCell: View {
    
    private let stufe: SeesturmStufe
    
    init(
        stufe: SeesturmStufe
    ) {
        self.stufe = stufe
    }
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .multilineTextAlignment(.leading)
                        .font(.title)
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
                HStack(alignment: .center, spacing: 8) {
                    ForEach(stufe.allowedAktivitaetInteractions.sorted { $0.id < $1.id }) { _ in
                        SeesturmButton(
                            type: .secondary,
                            action: .none,
                            title: "",
                            colors: .custom(contentColor: .clear, buttonColor: .skeletonPlaceholderColor),
                            disabled: true,
                            maxWidth: .infinity,
                            disabledAlpha: 1
                        )
                        .loadingBlinking()
                    }
                }
                SeesturmButton(
                    type: .primary,
                    action: .none,
                    title: "Bearbeiten",
                    icon: .system(name: "pencil"),
                    colors: .custom(contentColor: stufe.onHighContrastColor, buttonColor: stufe.highContrastColor),
                    disabled: true
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    VStack(spacing: 16) {
        StufenbereichAnAbmeldungCell(
            aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
                event: DummyData.aktivitaet1,
                anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2, DummyData.abmeldung3]
            ),
            stufe: .biber,
            isBearbeitenButtonLoading: true,
            onOpenSheet: { _ in},
            onSendPushNotification: {},
            onDeleteAnAbmeldungen: {},
            onEditAktivitaet: {},
            displayNavigationDestination: AccountNavigationDestination.anlaesse
        )
        StufenbereichAnAbmeldungLoadingCell(stufe: .biber)
    }
}
