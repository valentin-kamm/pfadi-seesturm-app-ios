//
//  AktivitaetHomeHorizontalScrollView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.02.2025.
//
import SwiftUI

struct AktivitaetHomeHorizontalScrollView: View {
    
    let stufen: Set<SeesturmStufe>
    let naechsteAktivtaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>]
    let screenWidth: CGFloat
    let onRetry: (SeesturmStufe) async -> Void
    
    var sortedStufen: [SeesturmStufe] {
        Array(stufen).sorted(by: { $0.id < $1.id })
    }
    var cardWidth: CGFloat {
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
                            CardErrorView(
                                errorDescription: message,
                                asyncRetryAction: {
                                    await onRetry(stufe)
                                }
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
    AktivitaetHomeHorizontalScrollView(
        stufen: [.biber, .wolf, .pfadi, .pio],
        naechsteAktivtaetState: [
            .biber: .success(data: try! GoogleCalendarEventDto(
                id: "17v15laf167s75oq47elh17a3t",
                summary: "Pfadistufenaktivität Pfadistufenaktivität",
                description: "\n<p>Das Kantonale Pfaditreffen (KaTre) findet dieses Jahr am Wochenende vom <strong>21. und 22. September</strong> in <strong>Frauenfeld </strong>statt. Dieses Jahr steht das KaTre unter dem Motto &#171;<strong>Schräg ide Ziit</strong>&#187; und passend zum Motto werden wir nicht nur die Thurgauer Kantonshauptstadt besuchen, sondern auch eine spannende Reise in das Jahr 1999 unternehmen.</p>\n\n\n\n<p>Für die <strong>Pfadi- und Piostufe</strong> beginnt das Programm bereits am Samstagmittag und dauert bis Sonntagnachmittag, während es für die <strong>Wolfstufe</strong> und <strong>Biber</strong> am Sonntag startet. Wir würden uns sehr freuen, wenn sich möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2024/06/KaTre1999_Anmeldetalon.pdf\">Anmeldeformular</a> aus und sendet es <strong>bis am 23. Juni</strong> an <a href=\"mailto: al@seesturm.ch\">al@seesturm.ch</a>.</p>\n",
                location: "Pfadiheim",
                created: "2022-08-28T15:25:45.726Z",
                updated: "2022-08-28T15:25:45.726Z",
                start: GoogleCalendarEventStartEndDto(
                    dateTime: "2022-08-27T06:00:00Z",
                    date: nil
                ),
                end: GoogleCalendarEventStartEndDto(
                    dateTime: "2022-08-27T10:00:00Z",
                    date: nil
                )
            ).toGoogleCalendarEvent()
                             ),
            .wolf: .success(data: try! GoogleCalendarEventDto(
                id: "17v15laf167s75oq47elh17a3t",
                summary: "Pfadistufenaktivität Pfadistufenaktivität",
                description: "\n<p>Das Kantonale Pfaditreffen (KaTre) findet dieses Jahr am Wochenende vom <strong>21. und 22. September</strong> in <strong>Frauenfeld </strong>statt. Dieses Jahr steht das KaTre unter dem Motto &#171;<strong>Schräg ide Ziit</strong>&#187; und passend zum Motto werden wir nicht nur die Thurgauer Kantonshauptstadt besuchen, sondern auch eine spannende Reise in das Jahr 1999 unternehmen.</p>\n\n\n\n<p>Für die <strong>Pfadi- und Piostufe</strong> beginnt das Programm bereits am Samstagmittag und dauert bis Sonntagnachmittag, während es für die <strong>Wolfstufe</strong> und <strong>Biber</strong> am Sonntag startet. Wir würden uns sehr freuen, wenn sich möglichst viele Seestürmlerinnen und Seestürmler aller Stufen anmelden. Füllt dazu einfach das <a href=\"https: //seesturm.ch/wp-content/uploads/2024/06/KaTre1999_Anmeldetalon.pdf\">Anmeldeformular</a> aus und sendet es <strong>bis am 23. Juni</strong> an <a href=\"mailto: al@seesturm.ch\">al@seesturm.ch</a>.</p>\n",
                location: "Pfadiheim",
                created: "2022-08-28T15:25:45.726Z",
                updated: "2022-08-28T15:25:45.726Z",
                start: GoogleCalendarEventStartEndDto(
                    dateTime: "2022-08-27T06:00:00Z",
                    date: nil
                ),
                end: GoogleCalendarEventStartEndDto(
                    dateTime: "2022-08-27T10:00:00Z",
                    date: nil
                )
            ).toGoogleCalendarEvent()
                            ),
            .pfadi: .loading(subState: .loading),
            .pio: .error(message: "Test")
        ],
        screenWidth: 400.0,
        onRetry: { stufe in }
    )
}
