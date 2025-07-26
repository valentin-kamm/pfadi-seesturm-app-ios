//
//  StufenbereichAnAbmeldungenCell.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.12.2024.
//

import SwiftUI

struct StufenbereichAnAbmeldungCell<D: NavigationDestination>: View {
    
    private let aktivitaet: GoogleCalendarEventWithAnAbmeldungen
    private let stufe: SeesturmStufe
    private let selectedAktivitaetInteraction: Binding<AktivitaetInteractionType>
    private let isBearbeitenButtonLoading: Bool
    private let onSendPushNotification: () -> Void
    private let onDeleteAnAbmeldungen: () -> Void
    private let onEditAktivitaet: () -> Void
    private let displayNavigationDestination: D
    
    init(
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen,
        stufe: SeesturmStufe,
        selectedAktivitaetInteraction: Binding<AktivitaetInteractionType>,
        isBearbeitenButtonLoading: Bool,
        onSendPushNotification: @escaping () -> Void,
        onDeleteAnAbmeldungen: @escaping () -> Void,
        onEditAktivitaet: @escaping () -> Void,
        displayNavigationDestination: D
    ) {
        self.aktivitaet = aktivitaet
        self.stufe = stufe
        self.selectedAktivitaetInteraction = selectedAktivitaetInteraction
        self.isBearbeitenButtonLoading = isBearbeitenButtonLoading
        self.onSendPushNotification = onSendPushNotification
        self.onDeleteAnAbmeldungen = onDeleteAnAbmeldungen
        self.onEditAktivitaet = onEditAktivitaet
        self.displayNavigationDestination = displayNavigationDestination
    }
    
    private var filteredAnAbmeldungen: [AktivitaetAnAbmeldung] {
        aktivitaet.anAbmeldungen.filter { $0.type == selectedAktivitaetInteraction.wrappedValue }
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
                        Text(aktivitaet.event.fullDateTimeFormatted)
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
                    ForEach(stufe.allowedAktivitaetInteractions.sorted { $0.id < $1.id }) { interaction in
                        Label(aktivitaet.displayTextAnAbmeldungen(interaction: interaction), systemImage: interaction.icon)
                            .font(.caption)
                            .lineLimit(1)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.seesturmGray)
                            )
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(interaction.color)
                            .onTapGesture {
                                withAnimation {
                                    selectedAktivitaetInteraction.wrappedValue = interaction
                                }
                            }
                    }
                }
                CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                    switch filteredAnAbmeldungen.isEmpty {
                    case true:
                        Text("Keine \(selectedAktivitaetInteraction.wrappedValue.nomenMehrzahl)")
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
                                        .font(.caption)
                                        .foregroundStyle(abmeldung.type.color)
                                        .labelStyle(.titleAndIcon)
                                    Text(abmeldung.bemerkungForDisplay)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
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
                                onSendPushNotification()
                            },
                            disabled: aktivitaet.event.hasStarted
                        ),
                        DropdownItemImpl(
                            title: "An- und Abmeldungen löschen",
                            item: "An- und Abmeldungen löschen",
                            icon: .custom(systemName: "trash"),
                            action: {
                                onDeleteAnAbmeldungen()
                            },
                            disabled: !aktivitaet.event.hasEnded || aktivitaet.anAbmeldungen.isEmpty
                        )
                    ],
                    title: "Bearbeiten",
                    icon: .system(name: "pencil"),
                    colors: .custom(contentColor: stufe.onHighContrastColor, buttonColor: stufe.highContrastColor),
                    isLoading: isBearbeitenButtonLoading,
                    disabled: isBearbeitenButtonLoading
                )
                .frame(maxWidth: .infinity, alignment: .center)
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
            anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2]
        ),
        stufe: .biber,
        selectedAktivitaetInteraction: .constant(.anmelden),
        isBearbeitenButtonLoading: true,
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
            anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2]
        ),
        stufe: .biber,
        selectedAktivitaetInteraction: .constant(.abmelden),
        isBearbeitenButtonLoading: false,
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
        stufe: .biber,
        selectedAktivitaetInteraction: .constant(.abmelden),
        isBearbeitenButtonLoading: false,
        onSendPushNotification: {},
        onDeleteAnAbmeldungen: {},
        onEditAktivitaet: {},
        displayNavigationDestination: AccountNavigationDestination.anlaesse
    )
}
