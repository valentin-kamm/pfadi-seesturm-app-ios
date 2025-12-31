//
//  GoogleCalendarEventWithAnAbmeldungen.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct GoogleCalendarEventWithAnAbmeldungen: Hashable, Identifiable {
    var event: GoogleCalendarEvent
    var anAbmeldungen: [AktivitaetAnAbmeldung]
    
    var id: String {
        self.event.id
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
