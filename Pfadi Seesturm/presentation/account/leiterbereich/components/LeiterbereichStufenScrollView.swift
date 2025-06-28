//
//  LeiterbereichStufenScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI

struct LeiterbereichStufenScrollView: View {
    
    private let stufen: [SeesturmStufe]
    private let screenWidth: CGFloat
    private let onNeueAktivitaetButtonClick: (SeesturmStufe) -> Void
    
    init(
        stufen: [SeesturmStufe],
        screenWidth: CGFloat,
        onNeueAktivitaetButtonClick: @escaping (SeesturmStufe) -> Void
    ) {
        self.stufen = stufen
        self.screenWidth = screenWidth
        self.onNeueAktivitaetButtonClick = onNeueAktivitaetButtonClick
    }
    
    private var cardWidth: CGFloat {
        if stufen.count <= 1 {
            return screenWidth - 32
        }
        else if stufen.count == 2 {
            return (screenWidth - 48) / 2
        }
        else {
            return 0.85 * (screenWidth - 48) / 2
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                if stufen.isEmpty {
                    Text("Keine Stufe ausgewählt")
                        .padding(.top)
                        .frame(width: screenWidth, height: 160)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .multilineTextAlignment(.center)
                }
                else {
                    ForEach(Array(stufen.sorted { $0.id < $1.id }.enumerated()), id: \.element.id) { index, stufe in
                        LeiterbereichStufeCardView(
                            width: cardWidth,
                            stufe: stufe,
                            onButtonClick: {
                                onNeueAktivitaetButtonClick(stufe)
                            },
                            navigationDestination: AccountNavigationDestination.stufenbereich(stufe: stufe)
                        )
                        .padding(.leading, index == 0 ? 16 : 0)
                        .padding(.trailing, index == stufen.count - 1 ? 16 : 0)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    GeometryReader { geometry in
        
        let width = geometry.size.width
        
        VStack(alignment: .center, spacing: 16) {
            LeiterbereichStufenScrollView(
                stufen: [],
                screenWidth: width,
                onNeueAktivitaetButtonClick: { _ in }
            )
            LeiterbereichStufenScrollView(
                stufen: [.biber],
                screenWidth: width,
                onNeueAktivitaetButtonClick: { _ in }
            )
            LeiterbereichStufenScrollView(
                stufen: [.biber, .wolf],
                screenWidth: width,
                onNeueAktivitaetButtonClick: { _ in }
            )
            LeiterbereichStufenScrollView(
                stufen: [.biber, .wolf, .pfadi, .pio],
                screenWidth: width,
                onNeueAktivitaetButtonClick: { _ in }
            )
        }
    }
}
