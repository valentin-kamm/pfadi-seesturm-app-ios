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
    var updated: Date
    var createdString: String
    var updatedString: String
    var isAllDay: Bool
    var firstDayOfMonthOfStartDate: Date
    var startDate: Date
    var endDate: Date
    var startDayString: String
    var startMonthString: String
    var endDateString: String?
    var timeString: String
    var fullDateTimeString: String
}
extension GoogleCalendarEvent {
    
    var showUpdated: Bool {
        let minuteDifference = Calendar.current.dateComponents([.minute], from: created, to: updated).minute
        if let diff = minuteDifference {
            return abs(diff) > 2
        }
        else {
            return false
        }
    }
    
    var hasEnded: Bool {
        endDate < Date()
    }
    var hasStarted: Bool {
        startDate <= Date()
    }
    
    func toAktivitaetWithAnAbmeldungen(anAbmeldungen: [AktivitaetAnAbmeldung]) -> GoogleCalendarEventWithAnAbmeldungen {
        return GoogleCalendarEventWithAnAbmeldungen(
            event: self,
            anAbmeldungen: getAnAbmeldungenForEventId(eventId: id, anAbmeldungen: anAbmeldungen)
        )
    }
    private func getAnAbmeldungenForEventId(eventId: String, anAbmeldungen: [AktivitaetAnAbmeldung]) -> [AktivitaetAnAbmeldung] {
        return anAbmeldungen.filter { $0.eventId == id }
    }
    
    func toCloudFunctionEventPayload() -> CloudFunctionEventPayload {
        return CloudFunctionEventPayload(
            summary: title,
            description: description ?? "",
            location: location ?? "",
            isAllDay: isAllDay,
            start: startDate,
            end: endDate
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
