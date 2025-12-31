//
//  StufenbereichAnAbmeldungSheet.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.12.2025.
//
import SwiftUI

struct StufenbereichAnAbmeldungSheet: View {
    
    @State private var interaction: AktivitaetInteractionType
    private let aktivitaet: GoogleCalendarEventWithAnAbmeldungen
    private let stufe: SeesturmStufe
    
    init(
        initialInteraction: AktivitaetInteractionType,
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen,
        stufe: SeesturmStufe
    ) {
        self._interaction = State(initialValue: initialInteraction)
        self.aktivitaet = aktivitaet
        self.stufe = stufe
    }
    
    private var filteredSortedAnAbmeldungen: [AktivitaetAnAbmeldung] {
        aktivitaet.anAbmeldungen
            .filter { $0.type == interaction }
            .sorted { $0.created > $1.created }
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            List {
                Section {
                    if filteredSortedAnAbmeldungen.isEmpty {
                        Text("Keine \(interaction.nomenMehrzahl)")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .font(.callout)
                            .padding()
                    }
                    else {
                        ForEach(Array(filteredSortedAnAbmeldungen.enumerated()), id: \.element.id) { index, abmeldung in
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(abmeldung.displayName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .fontWeight(.bold)
                                    .font(.callout)
                                Label("\(abmeldung.type.taetigkeit): \(abmeldung.createdString)", systemImage: abmeldung.type.icon)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .font(.footnote)
                                    .foregroundStyle(abmeldung.type.color)
                                    .labelStyle(.titleAndIcon)
                                Text(abmeldung.bemerkungForDisplay)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                    .font(.footnote)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                } header: {
                    if stufe.allowedAktivitaetInteractions.count > 1 {
                        Picker("An-/Abmeldung", selection: $interaction) {
                            ForEach(stufe.allowedAktivitaetInteractions.sorted { $0.id < $1.id }) { ai in
                                Text(ai.nomenMehrzahl)
                                    .tag(ai)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.bottom)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Aktivität vom \(aktivitaet.event.startDateFormatted)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Biber") {
    StufenbereichAnAbmeldungSheet(
        initialInteraction: .abmelden,
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: [DummyData.abmeldung1, DummyData.abmeldung2, DummyData.abmeldung3]
        ),
        stufe: .biber
    )
}
#Preview("Wolf") {
    StufenbereichAnAbmeldungSheet(
        initialInteraction: .abmelden,
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: [DummyData.abmeldung3]
        ),
        stufe: .wolf
    )
}
#Preview("Empty") {
    StufenbereichAnAbmeldungSheet(
        initialInteraction: .anmelden,
        aktivitaet: GoogleCalendarEventWithAnAbmeldungen(
            event: DummyData.aktivitaet1,
            anAbmeldungen: []
        ),
        stufe: .biber
    )
}
