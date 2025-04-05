//
//  AktivitaetDetailCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import SwiftUI
import RichText

struct AktivitaetDetailCardView: View {
    
    let stufe: SeesturmStufe
    let aktivitaet: GoogleCalendarEvent?
    let openSheet: (AktivitaetInteraction) -> Void
    let isPreview: Bool
    
    var body: some View {
        CustomCardView {
            if let aktivitaet = aktivitaet {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(aktivitaet.title)
                                .multilineTextAlignment(.leading)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Label {
                                Text("Veröffentlicht: ")
                                    .font(.caption2)
                                    .fontWeight(.bold) +
                                Text(aktivitaet.createdString)
                                    .font(.caption2)
                            } icon: {
                                Image(systemName: "calendar.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .foregroundStyle(Color.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            if aktivitaet.showUpdated {
                                Label {
                                    Text("Aktualisiert: ")
                                        .font(.caption2)
                                        .fontWeight(.bold) +
                                    Text(aktivitaet.updatedString)
                                        .font(.caption2)
                                } icon: {
                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .aspectRatio(contentMode: .fit)
                                }
                                .foregroundStyle(Color.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        stufe.icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Label {
                        Text("Zeit: ")
                            .foregroundStyle(stufe.highContrastColor)
                            .font(.subheadline)
                            .fontWeight(.bold) +
                        Text(aktivitaet.fullDateTimeString)
                            .foregroundStyle(Color.secondary)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(stufe.highContrastColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if let ort = aktivitaet.location {
                        Label {
                            Text("Treffpunkt: ")
                                .foregroundStyle(stufe.highContrastColor)
                                .font(.subheadline)
                                .fontWeight(.bold) +
                            Text(ort)
                                .foregroundStyle(Color.secondary)
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "location")
                                .foregroundStyle(stufe.highContrastColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let beschreibung = aktivitaet.description {
                        Divider()
                        Label {
                            Text("Infos")
                                .foregroundStyle(stufe.highContrastColor)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(stufe.highContrastColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        RichText(html: beschreibung)
                            .transition(.none)
                            .linkOpenType(.SFSafariView())
                            .placeholder {
                                Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                                    .lineLimit(2)
                                    .font(.body)
                                    .redacted(reason: .placeholder)
                                    .customLoadingBlinking()
                                    .padding(.top, -16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(stufe.allowedAktivitaetInteractions.sorted(by: { $0.id > $1.id}), id: \.self) { interaction in
                            SeesturmButton(
                                style: .tertiary,
                                action: .sync(action: {
                                    self.openSheet(interaction)
                                }),
                                title: interaction.verb.capitalized,
                                icon: .system(name: interaction.icon),
                                colors: .custom(contentColor: .white, buttonColor: interaction.color),
                                isDisabled: isPreview
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            else {
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        Text(stufe.stufenName)
                            .multilineTextAlignment(.leading)
                            .font(.largeTitle)
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
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    Text("Aktiviere die Push-Nachrichten, um benachrichtigt zu werden, sobald die Aktivität fertig geplant ist.")
                        .foregroundStyle(Color.secondary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    NavigationLink(value: HomeNavigationDestination.pushNotifications) {
                        SeesturmButton(
                            style: .primary,
                            action: .none,
                            title: "Push-Nachrichten aktivieren",
                            isDisabled: true
                        )
                    }
                    .padding()
                }
                .padding()
            }
        }
        .padding()
    }
}

#Preview("Fertig geplant") {
    AktivitaetDetailCardView(
        stufe: .wolf,
        aktivitaet: try! GoogleCalendarEventDto(
            id: "17v15laf167s75oq47elh17a3t",
            summary: "Biberstufen-Aktivität",
            description: "Ob uns wohl der Pfadi-Chlaus dieses Jahr wieder viele Nüssli und Schöggeli bringt? Die genauen Zeiten werden später kommuniziert.",
            location: "Geiserparkplatz",
            created: "2022-08-28T15:25:45.701Z",
            updated: "2022-08-28T15:19:45.726Z",
            start: GoogleCalendarEventStartEndDto(
                dateTime: "2022-12-10T13:00:00Z",
                date: nil
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: "2022-12-10T15:00:00Z",
                date: nil
            )
        ).toGoogleCalendarEvent(),
        openSheet: { interaction in
            
        },
        isPreview: false
    )
}
#Preview("Noch in Planung") {
    AktivitaetDetailCardView(
        stufe: .biber,
        aktivitaet: nil,
        openSheet: { interaction in
            
        },
        isPreview: false
    )
}
