//
//  AnlaesseRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

protocol AnlaesseRepository {
    
    func getEvents(calendar: SeesturmCalendar, includePast: Bool, maxResults: Int) async throws -> GoogleCalendarEventsDto
    func getEvents(calendar: SeesturmCalendar, pageToken: String, maxResults: Int) async throws -> GoogleCalendarEventsDto
    func getEvents(calendar: SeesturmCalendar, timeMin: Date) async throws -> GoogleCalendarEventsDto
    func getEvent(calendar: SeesturmCalendar, eventId: String) async throws -> GoogleCalendarEventDto
    func getNextThreeEvents(calendar: SeesturmCalendar) async throws -> GoogleCalendarEventsDto
}
