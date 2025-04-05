//
//  LeiterbereichStufenScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2024.
//

import SwiftUI

struct LeiterbereichStufenScrollView: View {
    
    let selectedStufen: [SeesturmStufe]
    let screenWidth: CGFloat
    let onNeueAktivitaetButtonClick: (SeesturmStufe) -> Void
    
    var cardWidth: CGFloat {
        if selectedStufen.count <= 1 {
            return screenWidth - 32
        }
        else if selectedStufen.count == 2 {
            return (screenWidth - 48) / 2
        }
        else {
            return 0.85 * (screenWidth - 48) / 2
        }
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                if selectedStufen.isEmpty {
                    Text("Keine Stufe ausgewählt")
                        .padding(.top)
                        .frame(width: screenWidth, height: 160)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .multilineTextAlignment(.center)
                }
                else {
                    ForEach(Array(selectedStufen.sorted { $0.id < $1.id }.enumerated()), id: \.element.id) { index, stufe in
                        LeiterbereichStufeCardView(
                            width: cardWidth,
                            stufe: stufe,
                            onButtonClick: {
                                onNeueAktivitaetButtonClick(stufe)
                            },
                            navigationDestination: AccountNavigationDestination.stufenbereich(stufe: stufe, initialSheetMode: .hidden)
                        )
                        .padding(.leading, index == 0 ? 16 : 0)
                        .padding(.trailing, index == selectedStufen.count - 1 ? 16 : 0)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    LeiterbereichStufenScrollView(
        selectedStufen: [],
        screenWidth: 350,
        onNeueAktivitaetButtonClick: { _ in }
    )
}
