//
//  AktivitaetDetailCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.02.2025.
//
import SwiftUI
import RichText

struct AktivitaetDetailCardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    private let stufe: SeesturmStufe
    private let aktivitaet: GoogleCalendarEvent?
    private let openSheet: (AktivitaetInteractionType) -> Void
    private let type: AktivitaetDetailViewType
    
    init(
        stufe: SeesturmStufe,
        aktivitaet: GoogleCalendarEvent?,
        openSheet: @escaping (AktivitaetInteractionType) -> Void,
        type: AktivitaetDetailViewType
    ) {
        self.stufe = stufe
        self.aktivitaet = aktivitaet
        self.openSheet = openSheet
        self.type = type
    }
    
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
                                Text(aktivitaet.createdFormatted)
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
                                    Text(aktivitaet.modifiedFormatted)
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
                        Text(aktivitaet.fullDateTimeFormatted)
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
                                    .loadingBlinking()
                                    .padding(.top, -16)
                            }
                            .customCSS("html * { background-color: transparent;}")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Divider()
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(stufe.allowedAktivitaetInteractions.sorted(by: { $0.id > $1.id})) { interaction in
                            SeesturmButton(
                                type: .secondary,
                                action: .sync(action: {
                                    self.openSheet(interaction)
                                }),
                                title: interaction.verb.capitalized,
                                icon: .system(name: interaction.icon),
                                colors: .custom(contentColor: .white, buttonColor: interaction.color),
                                disabled: type != .home
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
                        Text(stufe.name)
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
                            type: .primary,
                            action: .none,
                            title: "Push-Nachrichten aktivieren",
                            disabled: true,
                            disabledAlpha: 1.0
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

#Preview("Noch in Planung") {
    AktivitaetDetailCardView(
        stufe: .pfadi,
        aktivitaet: nil,
        openSheet: { _ in },
        type: .home
    )
}
#Preview("With interaction") {
    AktivitaetDetailCardView(
        stufe: .pfadi,
        aktivitaet: DummyData.aktivitaet1,
        openSheet: { _ in },
        type: .home
    )
}
#Preview("View only") {
    AktivitaetDetailCardView(
        stufe: .pfadi,
        aktivitaet: DummyData.aktivitaet1,
        openSheet: { _ in },
        type: .display
    )
}
