//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

// response when fetching events
struct GoogleCalendarEventsDto: Codable {
    var updated: String
    var timeZone: String
    var nextPageToken: String?
    var items: [GoogleCalendarEventDto]
}

extension GoogleCalendarEventsDto {
    func toGoogleCalendarEvents() throws -> GoogleCalendarEvents {
            
        guard let calendarTimeZone = TimeZone(identifier: timeZone) else {
            throw PfadiSeesturmError.dateError(message: "Ungültige Zeitzone.")
        }
        let targetDisplayTimezone = TimeZone(identifier: "Europe/Zurich")!
        let updatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: updated)
        
        return GoogleCalendarEvents(
            updatedFormatted: DateTimeUtil.shared.formatDate(
                date: updatedDate,
                format: "dd. MMMM yyyy",
                timeZone: targetDisplayTimezone,
                type: .relative(withTime: false)
            ),
            timeZone: calendarTimeZone,
            nextPageToken: nextPageToken,
            items: try items.map { try $0.toGoogleCalendarEvent(calendarTimeZone: calendarTimeZone) }
        )
    }
}
