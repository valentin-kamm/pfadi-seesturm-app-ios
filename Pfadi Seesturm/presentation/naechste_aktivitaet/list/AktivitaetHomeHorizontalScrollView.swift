//
//  AktivitaetHomeHorizontalScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.02.2025.
//
import SwiftUI

struct AktivitaetHomeHorizontalScrollView: View {
    
    private let stufen: Set<SeesturmStufe>
    private let naechsteAktivtaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>]
    private let screenWidth: CGFloat
    private let onRetry: (SeesturmStufe) async -> Void
    
    init(
        stufen: Set<SeesturmStufe>,
        naechsteAktivtaetState: [SeesturmStufe : UiState<GoogleCalendarEvent?>],
        screenWidth: CGFloat,
        onRetry: @escaping (SeesturmStufe) async -> Void
    ) {
        self.stufen = stufen
        self.naechsteAktivtaetState = naechsteAktivtaetState
        self.screenWidth = screenWidth
        self.onRetry = onRetry
    }
    
    private var sortedStufen: [SeesturmStufe] {
        Array(stufen).sorted(by: { $0.id < $1.id })
    }
    private var cardWidth: CGFloat {
        stufen.count == 1 ? screenWidth - 32 : 0.85 * screenWidth
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(Array(sortedStufen.enumerated()), id: \.element.id) { index, stufe in
                    if let stufenState = naechsteAktivtaetState[stufe] {
                        switch stufenState {
                        case .loading(_):
                            AktivitaetHomeLoadingView(
                                width: cardWidth
                            )
                            .padding(.leading, index == 0 ? 16 : 0)
                            .padding(.trailing, index == stufen.count - 1 ? 16 : 0)
                        case .error(let message):
                            ErrorCardView(
                                errorDescription: message,
                                action: .async(action: {
                                    await onRetry(stufe)
                                })
                            )
                            .padding(.horizontal, -16)
                            .frame(width: cardWidth)
                            .padding(.vertical)
                            .padding(.leading, index == 0 ? 16 : 0)
                            .padding(.trailing, index == stufen.count - 1 ? 16 : 0)
                        case .success(let aktivitaet):
                            NavigationLink(value: HomeNavigationDestination.aktivitaetDetail(inputType: .object(object: aktivitaet), stufe: stufe)) {
                                AktivitaetHomeCardView(
                                    width: cardWidth,
                                    stufe: stufe,
                                    aktivitaet: aktivitaet
                                )
                            }
                            .padding(.leading, index == 0 ? 16 : 0)
                            .padding(.trailing, index == stufen.count - 1 ? 16 : 0)
                            .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    GeometryReader { geometry in
        AktivitaetHomeHorizontalScrollView(
            stufen: [.biber, .wolf, .pfadi, .pio],
            naechsteAktivtaetState: [
                .biber: .loading(subState: .loading),
                .wolf: .error(message: "Schwerer Fehler"),
                .pfadi: .success(data: nil),
                .pio: .success(data: DummyData.aktivitaet1)
            ],
            screenWidth: geometry.size.width,
            onRetry: { _ in }
        )
    }
}
