//
//  ErrorCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct ErrorCardView: View {
    
    private let errorTitle: String
    private let errorDescription: String
    private let action: SeesturmButtonAction?
    
    init(
        errorTitle: String = "Ein Fehler ist aufgetreten",
        errorDescription: String,
        action: SeesturmButtonAction? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorDescription = errorDescription
        self.action = action
    }
    
    var body: some View {
        CustomCardView(shadowColor: Color.seesturmGreenCardViewShadowColor) {
            ContentUnavailableView(
                label: {
                    Label(errorTitle, systemImage: "exclamationmark.bubble")
                },
                description: {
                    Text(errorDescription)
                },
                actions: {
                    if let a = action {
                        SeesturmButton(
                            type: .secondary,
                            action: a,
                            title: "Erneut versuchen"
                        )
                    }
                }
            )
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ErrorCardView(
        errorDescription: "Die vom Server übermittelten Daten sind ungültig.",
        action: .sync(action: {
            print("Retry button clicked.")
        })
    )
}

#Preview {
    ErrorCardView(
        errorDescription: "Die vom Server übermittelten Daten sind ungültig."
    )
}
