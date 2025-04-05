//
//  CardErrorView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct CardErrorView: View {
    
    // parameters passed to this view
    let errorTitle: String
    let errorDescription: String
    let retryAction: (() -> Void)?
    let asyncRetryAction: (() async -> Void)?
    
    init(
        errorTitle: String = "Ein Fehler ist aufgetreten",
        errorDescription: String,
        retryAction: (() -> Void)? = nil,
        asyncRetryAction: (() async -> Void)? = nil
    ) {
        self.errorTitle = errorTitle
        self.errorDescription = errorDescription
        self.retryAction = retryAction
        self.asyncRetryAction = asyncRetryAction
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
                    if let asRetryAction = asyncRetryAction {
                        SeesturmButton(
                            style: .tertiary,
                            action: .async(action: asRetryAction),
                            title: "Erneut versuchen"
                        )
                    }
                    else if let retryAction = retryAction {
                        SeesturmButton(
                            style: .tertiary,
                            action: .sync(action: retryAction),
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
    CardErrorView(
        errorTitle: "Ein Fehler ist aufgetreten",
        errorDescription: "Die vom Server übermittelten Daten sind ungültig.",
        retryAction: {
            print("Retry button clicked.")
        }
    )
}
