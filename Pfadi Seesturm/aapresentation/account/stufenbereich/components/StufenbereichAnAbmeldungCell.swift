//
//  StufenbereichAnAbmeldungenCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungCell: View {
    
    let aktivitaet: GoogleCalendarEventWithAnAbmeldungen
    let stufe: SeesturmStufe
    let selectedAktivitaetInteraction: AktivitaetInteraction
    let isBearbeitenButtonLoading: Bool
    let onSendPushNotification: () -> Void
    let onDeleteAnAbmeldungen: () -> Void
    let onEditAktivitaet: () -> Void
    let onChangeSelectedAktivitaetInteraction: (AktivitaetInteraction) -> Void
    
    var filteredAnAbmeldungen: [AktivitaetAnAbmeldung] {
        aktivitaet.anAbmeldungen.filter { $0.type == selectedAktivitaetInteraction }
    }
    
    var body: some View {
        CustomCardView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(aktivitaet.event.title)
                            .multilineTextAlignment(.leading)
                            .font(.callout)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(aktivitaet.event.fullDateTimeString)
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    stufe.icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                HStack(alignment: .center, spacing: 8) {
                    ForEach(stufe.allowedAktivitaetInteractions.sorted { $0.id < $1.id }, id: \.self) { interaction in
                        Label(aktivitaet.displayTextAnAbmeldungen(interaction: interaction), systemImage: interaction.icon)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(UIColor.systemGray5))
                            )
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(interaction.color)
                            .onTapGesture {
                                onChangeSelectedAktivitaetInteraction(interaction)
                            }
                    }
                }
                CustomCardView(shadowColor: .clear, backgroundColor: Color(UIColor.systemGray5)) {
                    switch filteredAnAbmeldungen.isEmpty {
                    case true:
                        Text("Keine \(selectedAktivitaetInteraction.nomenMehrzahl)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .padding()
                    default:
                        VStack(alignment: .center, spacing: 16) {
                            ForEach(Array(filteredAnAbmeldungen.sorted { $0.created > $1.created }.enumerated()), id: \.element.id) { index, abmeldung in
                                
                                if index > 0 {
                                    Divider()
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(abmeldung.displayName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .fontWeight(.bold)
                                        .font(.caption)
                                    Label("\(abmeldung.type.taetigkeit): \(abmeldung.createdString)", systemImage: abmeldung.type.icon)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                        .foregroundStyle(abmeldung.type.color)
                                        .labelStyle(.titleAndIcon)
                                    Text(abmeldung.bemerkungForDisplay)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                DropdownButton(
                    items: [
                        DropdownItemImpl(
                            title: "An- und Abmeldungen löschen",
                            item: "An- und Abmeldungen löschen",
                            icon: .custom(systemName: "trash"),
                            action: {
                                onDeleteAnAbmeldungen()
                            },
                            disabled: !aktivitaet.event.hasEnded || aktivitaet.anAbmeldungen.isEmpty
                        ),
                        DropdownItemImpl(
                            title: "Push-Nachricht senden",
                            item: "Push-Nachricht senden",
                            icon: .custom(systemName: "bell.badge"),
                            action: {
                                onSendPushNotification()
                            },
                            disabled: aktivitaet.event.hasStarted
                        ),
                        DropdownItemImpl(
                            title: "Aktivität bearbeiten",
                            item: "Aktivität bearbeiten",
                            icon: .custom(systemName: "pencil"),
                            action: {
                                onEditAktivitaet()
                            },
                            disabled: aktivitaet.event.hasStarted
                        )
                    ],
                    title: "Bearbeiten",
                    icon: .system(name: "pencil"),
                    colors: .custom(contentColor: .white, buttonColor: stufe.highContrastColor),
                    isLoading: isBearbeitenButtonLoading,
                    isDisabled: isBearbeitenButtonLoading
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    StufenbereichAnAbmeldungCell(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: TermineCardViewPreviewExtension().oneDayEventData(),
            anAbmeldungen: [
                AktivitaetAnAbmeldung(
                    id: "xcvxfdsfgdsf",
                    eventId: "17v15laf167s75oq47elh17a3t",
                    uid: "klajflaksjf",
                    vorname: "Seppli",
                    nachname: "Meier",
                    type: .abmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute",
                    modifiedString: "Morgen"
                ),
                AktivitaetAnAbmeldung(
                    id: "sfdsdsfdsf",
                    eventId: "17v15laf167s75oq47elh17a3t",
                    uid: "klajflaksjf",
                    vorname: "Seppli",
                    nachname: "Meier",
                    type: .anmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute",
                    modifiedString: "Morgen"
                ),
                AktivitaetAnAbmeldung(
                    id: "adfskuahsdk",
                    eventId: "17v15laf167s75oq47elh17a3t",
                    uid: "wrswr",
                    vorname: "Michi",
                    nachname: "Meier",
                    type: .abmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute",
                    modifiedString: "Morgen"
                ),
                AktivitaetAnAbmeldung(
                    id: "wklwrl",
                    eventId: "17v15laf167s75oq47elh17a3t",
                    uid: "2342334",
                    vorname: "Peter",
                    nachname: "Meier",
                    type: .abmelden,
                    stufe: .biber,
                    created: Date(),
                    modified: Date(),
                    createdString: "Heute",
                    modifiedString: "Morgen"
                )
            ]
        ),
        stufe: .biber,
        selectedAktivitaetInteraction: .abmelden,
        isBearbeitenButtonLoading: false,
        onSendPushNotification: {},
        onDeleteAnAbmeldungen: {},
        onEditAktivitaet: {},
        onChangeSelectedAktivitaetInteraction: { _ in}
    )
}
