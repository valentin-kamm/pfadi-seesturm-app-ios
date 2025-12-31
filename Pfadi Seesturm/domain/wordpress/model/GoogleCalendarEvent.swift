//
//  GoogleCalendarEvent.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

struct GoogleCalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String?
    let location: String?
    let created: Date
    let modified: Date
    let createdFormatted: String
    let modifiedFormatted: String
    let isAllDay: Bool
    let firstDayOfMonthOfStartDate: Date
    let start: Date
    let end: Date
    let startDateFormatted: String
    let startDayFormatted: String
    let startMonthFormatted: String
    let endDateFormatted: String?
    let timeFormatted: String
    let fullDateTimeFormatted: String
}

extension GoogleCalendarEvent {
    
    var showUpdated: Bool {
        return abs(Calendar.current.dateComponents([.minute], from: created, to: modified).minute ?? 0) > 5
    }
    
    var hasEnded: Bool {
        end < Date()
    }
    
    var hasStarted: Bool {
        start <= Date()
    }
    
    func toAktivitaetWithAnAbmeldungen(anAbmeldungen: [AktivitaetAnAbmeldung]) -> GoogleCalendarEventWithAnAbmeldungen {
        return GoogleCalendarEventWithAnAbmeldungen(
            event: self,
            anAbmeldungen: anAbmeldungen.filter { $0.eventId == id }
        )
    }
}

extension [GoogleCalendarEvent] {
    var groupedByMonthAndYear: [(Date, [GoogleCalendarEvent])] {
        let grouped = Dictionary(grouping: self, by: { $0.firstDayOfMonthOfStartDate} )
        let sortedKeys = grouped.keys.sorted(by: <)
        return sortedKeys.map { startDate in
            (startDate, grouped[startDate] ?? [])
        }
    }
}
