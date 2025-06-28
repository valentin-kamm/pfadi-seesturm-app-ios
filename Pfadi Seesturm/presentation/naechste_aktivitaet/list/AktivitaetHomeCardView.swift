//
//  AktivitaetHomeCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI

struct AktivitaetHomeCardView: View {
    
    private let width: CGFloat
    private let stufe: SeesturmStufe
    private let aktivitaet: GoogleCalendarEvent?
    
    init(
        width: CGFloat,
        stufe: SeesturmStufe,
        aktivitaet: GoogleCalendarEvent?
    ) {
        self.width = width
        self.stufe = stufe
        self.aktivitaet = aktivitaet
    }
    
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

private struct AktivitaetHomeCardViewNochInPlanung: View {
    
    private let stufe: SeesturmStufe
    
    init(
        stufe: SeesturmStufe
    ) {
        self.stufe = stufe
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack {
                HStack(alignment: .top, spacing: 16) {
                    Text(stufe.name)
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

private struct AktivitaetHomeCardViewFinished: View {
    
    private let stufe: SeesturmStufe
    private let aktivitaet: GoogleCalendarEvent
    
    init(
        stufe: SeesturmStufe,
        aktivitaet: GoogleCalendarEvent
    ) {
        self.stufe = stufe
        self.aktivitaet = aktivitaet
    }
    
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
                        Label(aktivitaet.modifiedFormatted, systemImage: "arrow.trianglehead.2.clockwise")
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
                    Text(aktivitaet.fullDateTimeFormatted)
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
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding()
    }
}

#Preview("Noch in Planung") {
    GeometryReader { geometry in
        AktivitaetHomeCardView(
            width: geometry.size.width - 32,
            stufe: .biber,
            aktivitaet: nil
        )
        .padding()
    }
}
#Preview("Fertig geplant") {
    GeometryReader { geometry in
        AktivitaetHomeCardView(
            width: geometry.size.width - 32,
            stufe: .pfadi,
            aktivitaet: DummyData.aktivitaet1
        )
        .padding()
    }
}
