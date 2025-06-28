//
//  GoogleCalendarEvent.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

struct GoogleCalendarEvent: Identifiable, Hashable {
    var id: String
    var title: String
    var description: String?
    var location: String?
    var created: Date
    var modified: Date
    var createdFormatted: String
    var modifiedFormatted: String
    var isAllDay: Bool
    var firstDayOfMonthOfStartDate: Date
    var start: Date
    var end: Date
    var startDayFormatted: String
    var startMonthFormatted: String
    var endDateFormatted: String?
    var timeFormatted: String
    var fullDateTimeFormatted: String
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
