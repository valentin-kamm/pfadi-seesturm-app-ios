//
//  CalendarDataStructures.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//

import SwiftUI

// data structure for publishing/updating events
struct FCFAddEventRequest: Encodable {
    let calendarId: String
    let payload: CalendarEventPayload
}
struct FCFUpdateEventRequest: Encodable {
    let calendarId: String
    let eventId: String
    let payload: CalendarEventPayload
}
struct CalendarEventPayload: Encodable {
    var start: CalendarEventDateTimePayload
    var end: CalendarEventDateTimePayload
    var summary: String
    var location: String?
    var description: String?
    struct CalendarEventDateTimePayload: Encodable {
        var dateTime: String
    }
}
