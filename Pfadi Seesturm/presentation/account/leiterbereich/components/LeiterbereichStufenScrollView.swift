//
//  LeiterbereichStufenScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI

struct LeiterbereichStufenScrollView: View {
    
    private let stufen: [SeesturmStufe]
    private let totalContentWidth: CGFloat
    private let onNeueAktivitaetButtonClick: (SeesturmStufe) -> Void
    private let onNewMultiStufenAktivitaet: () -> Void
    
    init(
        stufen: [SeesturmStufe],
        totalContentWidth: CGFloat,
        onNeueAktivitaetButtonClick: @escaping (SeesturmStufe) -> Void,
        onNewMultiStufenAktivitaet: @escaping () -> Void
    ) {
        self.stufen = stufen
        self.totalContentWidth = totalContentWidth
        self.onNeueAktivitaetButtonClick = onNeueAktivitaetButtonClick
        self.onNewMultiStufenAktivitaet = onNewMultiStufenAktivitaet
    }
    
    private var scrollViewItemWidth: CGFloat {
        if stufen.count <= 1 {
            return totalContentWidth - 32
        }
        else if stufen.count == 2 {
            return (totalContentWidth - 48) / 2
        }
        else {
            return 0.95 * (totalContentWidth - 48) / 2
        }
    }
    
    var body: some View {
        CustomCardView {
            VStack(alignment: .center, spacing: 0) {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 16) {
                        if stufen.isEmpty {
                            Text("Keine Stufe ausgewählt")
                                .padding()
                                .frame(width: scrollViewItemWidth, height: 160)
                                .multilineTextAlignment(.center)
                        }
                        else {
                            ForEach(Array(stufen.sorted { $0.id < $1.id }.enumerated()), id: \.element.id) { index, stufe in
                                LeiterbereichStufeCardView(
                                    width: scrollViewItemWidth,
                                    stufe: stufe,
                                    onButtonClick: {
                                        onNeueAktivitaetButtonClick(stufe)
                                    },
                                    navigationDestination: AccountNavigationDestination.stufenbereich(stufe: stufe)
                                )
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .scrollDisabled(stufen.count < 1)
                .contentMargins(.horizontal, 16)
                SeesturmButton(
                    type: .secondary,
                    action: .sync(action: onNewMultiStufenAktivitaet),
                    title: "Aktivität für mehrere Stufen",
                    icon: .system(name: "plus"),
                    colors: .custom(contentColor: .primary, buttonColor: .primary),
                    style: .outlined
                )
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    GeometryReader { geometry in
        
        let width = geometry.size.width - 32
        
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                LeiterbereichStufenScrollView(
                    stufen: [],
                    totalContentWidth: width,
                    onNeueAktivitaetButtonClick: { _ in },
                    onNewMultiStufenAktivitaet: {}
                )
                .padding(.horizontal)
                LeiterbereichStufenScrollView(
                    stufen: [.biber],
                    totalContentWidth: width,
                    onNeueAktivitaetButtonClick: { _ in },
                    onNewMultiStufenAktivitaet: {}
                )
                .padding(.horizontal)
                LeiterbereichStufenScrollView(
                    stufen: [.biber, .wolf],
                    totalContentWidth: width,
                    onNeueAktivitaetButtonClick: { _ in },
                    onNewMultiStufenAktivitaet: {}
                )
                .padding(.horizontal)
                LeiterbereichStufenScrollView(
                    stufen: [.biber, .wolf, .pfadi, .pio],
                    totalContentWidth: width,
                    onNeueAktivitaetButtonClick: { _ in },
                    onNewMultiStufenAktivitaet: {}
                )
                .padding(.horizontal)
            }
        }
    }
}
