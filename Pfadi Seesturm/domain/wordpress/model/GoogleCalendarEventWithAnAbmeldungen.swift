//
//  GoogleCalendarEventWithAnAbmeldungen.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct GoogleCalendarEventWithAnAbmeldungen: Hashable {
    var event: GoogleCalendarEvent
    var anAbmeldungen: [AktivitaetAnAbmeldung]
}

extension GoogleCalendarEventWithAnAbmeldungen {
    func displayTextAnAbmeldungen(interaction: AktivitaetInteractionType) -> String {
        let count = anAbmeldungen.count { $0.type == interaction }
        return count == 1 ? "\(count) \(interaction.nomen)" : "\(count) \(interaction.nomenMehrzahl)"
    }
}

extension [GoogleCalendarEventWithAnAbmeldungen] {
    var groupesByMonthAndYear: [(Date, [GoogleCalendarEventWithAnAbmeldungen])] {
        let grouped = Dictionary(grouping: self, by: { $0.event.firstDayOfMonthOfStartDate })
        let sortedKeys = grouped.keys.sorted(by: >)
        return sortedKeys.map { startDate in
            (startDate, grouped[startDate] ?? [])
        }
    }
}
