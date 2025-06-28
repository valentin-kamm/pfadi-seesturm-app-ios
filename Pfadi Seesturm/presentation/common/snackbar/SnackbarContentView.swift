//
//  SnackbarContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.06.2025.
//

import SwiftUI

struct SnackbarContentView: View {
    
    private let type: SeesturmSnackbarType
    private let message: String
    
    init(
        type: SeesturmSnackbarType,
        message: String
    ) {
        self.type = type
        self.message = message
    }
    
    var body: some View {
        CustomCardView(shadowColor: .clear, backgroundColor: type.backgroundColor) {
            HStack(alignment: .center, spacing: 16) {
                type.icon
                    .resizable()
                    .foregroundColor(.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                Text(message)
                    .foregroundColor(.white)
                    .font(.footnote)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(alignment: .leading)
                    .layoutPriority(1)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.move(edge: .bottom))
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SnackbarContentView(
            type: .error,
            message: Constants.PLACEHOLDER_TEXT
        )
        SnackbarContentView(
            type: .success,
            message: Constants.PLACEHOLDER_TEXT
        )
        SnackbarContentView(
            type: .info,
            message: Constants.PLACEHOLDER_TEXT
        )
    }
    .padding()
}
