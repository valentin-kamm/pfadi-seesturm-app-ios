//
//  AktivitaetHomeCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI

struct AktivitaetHomeCardView: View {
    
    var width: CGFloat
    var stufe: SeesturmStufe
    var aktivitaet: GoogleCalendarEvent?
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            if let a = aktivitaet {
                AktivitaetHomeCardViewFinished(stufe: stufe, aktivitaet: a)
            }
            else {
                AktivitaetHomeCardViewNochInPlanung(stufe: stufe)
            }
        }
        .frame(width: width)
        .padding(.vertical)
    }
}

struct AktivitaetHomeCardViewNochInPlanung: View {
    var stufe: SeesturmStufe
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack {
                HStack(alignment: .top, spacing: 16) {
                    Text(stufe.stufenName)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    stufe.icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                Text("Die nächste Aktivität ist noch in Planung.")
                    .foregroundStyle(Color.secondary)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.vertical)
                    .lineLimit(2)
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
}

struct AktivitaetHomeCardViewFinished: View {
    
    var stufe: SeesturmStufe
    var aktivitaet: GoogleCalendarEvent
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(aktivitaet.title)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Label(aktivitaet.updatedString, systemImage: "arrow.trianglehead.2.clockwise")
                            .lineLimit(1)
                            .font(.caption2)
                            .foregroundStyle(Color.secondary)
                            .labelStyle(.titleAndIcon)
                    }
                    stufe.icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                Label {
                    Text(aktivitaet.fullDateTimeString)
                        .foregroundStyle(Color.secondary)
                        .font(.subheadline)
                        .lineLimit(3)
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundStyle(stufe.color)
                }
            }
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.secondary)
        }
            .padding()
    }
    
}

#Preview("Fertig geplant") {
    AktivitaetHomeCardView(
        width: 350,
        stufe: .wolf,
        aktivitaet: AktivitaetHomeCardViewPreviewExtension().biberstufeAktivitaet()
    )
}

#Preview("Noch in Planung") {
    AktivitaetHomeCardView(
        width: 350,
        stufe: .wolf,
        aktivitaet: nil
    )
}

struct AktivitaetHomeCardViewPreviewExtension {
    func biberstufeAktivitaet() -> GoogleCalendarEvent {
        return try! GoogleCalendarEventDto(
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
    }

}

struct NaechsteAktivitaetButtonConfig: ButtonStyle {
    var stufe: SeesturmStufeOld
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(stufe.color)
            .foregroundStyle(stufe.color)
    }
}
