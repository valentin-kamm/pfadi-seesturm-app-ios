//
//  GoogleCalendarEvents.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

struct GoogleCalendarEvents {
    var updatedFormatted: String
    var timeZone: TimeZone
    var nextPageToken: String?
    var items: [GoogleCalendarEvent]
}
