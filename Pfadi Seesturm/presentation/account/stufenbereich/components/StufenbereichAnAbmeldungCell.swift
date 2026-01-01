//
//  StufenbereichAnAbmeldungenCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungCell<D: NavigationDestination>: View {
    
    @State private var showDeleteAbmeldungenConfirmationDialog: Bool = false
    @State private var showSendPushNotificationConfirmationDialog: Bool = false
    
    private let aktivitaet: GoogleCalendarEventWithAnAbmeldungen
    private let stufe: SeesturmStufe
    private let isBearbeitenButtonLoading: Bool
    private let onOpenSheet: (AktivitaetInteractionType) -> Void
    private let onSendPushNotification: () -> Void
    private let onDeleteAnAbmeldungen: () -> Void
    private let onEditAktivitaet: () -> Void
    private let displayNavigationDestination: D
    
    init(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen,
        stufe: SeesturmStufe,
        isBearbeitenButtonLoading: Bool,
        onOpenSheet: @escaping (AktivitaetInteractionType) -> Void,
        onSendPushNotification: @escaping () -> Void,
        onDeleteAnAbmeldungen: @escaping () -> Void,
        onEditAktivitaet: @escaping () -> Void,
        displayNavigationDestination: D
    ) {
        self.aktivitaet = aktivitaet
        self.stufe = stufe
        self.isBearbeitenButtonLoading = isBearbeitenButtonLoading
        self.onOpenSheet = onOpenSheet
        self.onSendPushNotification = onSendPushNotification
        self.onDeleteAnAbmeldungen = onDeleteAnAbmeldungen
        self.onEditAktivitaet = onEditAktivitaet
        self.displayNavigationDestination = displayNavigationDestination
    }
    
    private var anAbmeldungenCount: [AktivitaetInteractionType: Int] {
        stufe.allowedAktivitaetInteractions.reduce(into: [:]) { result, type in
            result[type] = aktivitaet.anAbmeldungen.filter { $0.type == type }.count
        }
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
                        Label {
                            Text(aktivitaet.event.fullDateTimeFormatted)
                        } icon: {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(stufe.highContrastColor)
                        }
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if let ort = aktivitaet.event.location {
                            Label {
                                Text(ort)
                            } icon: {
                                Image(systemName: "location")
                                    .foregroundStyle(stufe.highContrastColor)
                            }
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    stufe.icon
                        .resizable()
                        .frame(width: 40, height: 40)
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                HStack(alignment: .center, spacing: 8) {
                    ForEach(Array(anAbmeldungenCount).sorted { $0.key.id < $1.key.id }, id: \.key) { interaction, count in
                        SeesturmButton(
                            type: .secondary,
                            action: .sync(action: { onOpenSheet(interaction) }),
                            title: "\(count) \(count == 1 ? interaction.nomen : interaction.nomenMehrzahl)",
                            icon: .system(name: interaction.icon),
                            colors: .custom(contentColor: interaction.color, buttonColor: .seesturmGray),
                            maxWidth: .infinity
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                DropdownButton(
                    items: [
                        DropdownItemImpl(
                            title: "Aktivität bearbeiten",
                            item: "Aktivität bearbeiten",
                            icon: .custom(systemName: "pencil"),
                            action: {
                                onEditAktivitaet()
                            },
                            disabled: aktivitaet.event.hasStarted
                        ),
                        DropdownItemImpl(
                            title: "Push-Nachricht senden",
                            item: "Push-Nachricht senden",
                            icon: .custom(systemName: "bell.badge"),
                            action: {
                                showSendPushNotificationConfirmationDialog = true
                            },
                            disabled: aktivitaet.event.hasStarted
                        ),
                        DropdownItemImpl(
                            title: "An- und Abmeldungen löschen",
                            item: "An- und Abmeldungen löschen",
                            icon: .custom(systemName: "trash"),
                            action: {
                                showDeleteAbmeldungenConfirmationDialog = true
                            },
                            disabled: !aktivitaet.event.hasEnded || aktivitaet.anAbmeldungen.isEmpty
                        )
                    ],
                    type: .primary,
                    title: "Bearbeiten",
                    icon: .system(name: "pencil"),
                    colors: .custom(contentColor: stufe.onHighContrastColor, buttonColor: stufe.highContrastColor),
                    isLoading: isBearbeitenButtonLoading,
                    disabled: isBearbeitenButtonLoading
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .confirmationDialog(
                    "Die An- und Abmeldungen für die Aktivität vom \(aktivitaet.event.startDateFormatted) werden gelöscht. Fortfahren?",
                    isPresented: $showDeleteAbmeldungenConfirmationDialog,
                    titleVisibility: .visible
                ) {
                    Button("Abbrechen", role: .cancel) {}
                    Button("Löschen", role: .destructive) {
                        onDeleteAnAbmeldungen()
                    }
                }
                .confirmationDialog(
                    "Für die Aktivität vom \(aktivitaet.event.startDateFormatted) wird eine Push-Nachricht versendet. Fortfahren?",
                    isPresented: $showSendPushNotificationConfirmationDialog,
                    titleVisibility: .visible
                ) {
                    Button("Abbrechen", role: .cancel) {}
                    Button("Senden", role: .destructive) {
                        onSendPushNotification()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
        .background(
            NavigationLink(value: displayNavigationDestination) {
                EmptyView()
            }
                .opacity(0)
        )
    }
}

#Preview("Loading") {
    StufenbereichAnAbmeldungCell(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2, DummyData.abmeldung3]
        ),
        stufe: .biber,
        isBearbeitenButtonLoading: true,
        onOpenSheet: { _ in},
        onSendPushNotification: {},
        onDeleteAnAbmeldungen: {},
        onEditAktivitaet: {},
        displayNavigationDestination: AccountNavigationDestination.anlaesse
    )
}
#Preview("Idle") {
    StufenbereichAnAbmeldungCell(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2, DummyData.abmeldung3]
        ),
        stufe: .biber,
        isBearbeitenButtonLoading: false,
        onOpenSheet: { _ in},
        onSendPushNotification: {},
        onDeleteAnAbmeldungen: {},
        onEditAktivitaet: {},
        displayNavigationDestination: AccountNavigationDestination.anlaesse
    )
}
#Preview("Empty") {
    StufenbereichAnAbmeldungCell(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: []
        ),
        stufe: .wolf,
        isBearbeitenButtonLoading: false,
        onOpenSheet: { _ in},
        onSendPushNotification: {},
        onDeleteAnAbmeldungen: {},
        onEditAktivitaet: {},
        displayNavigationDestination: AccountNavigationDestination.anlaesse
    )
}
