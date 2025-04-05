//
//  AnlaesseRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

class AnlaesseRepositoryImpl: AnlaesseRepository {
       
    let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getEvents(calendar: SeesturmCalendar, includePast: Bool, maxResults: Int) async throws -> GoogleCalendarEventsDto {
        return try await api.getEvents(calendarId: calendar.data.calendarId, includePast: includePast, maxResults: maxResults)
    }
    func getEvents(calendar: SeesturmCalendar, pageToken: String, maxResults: Int) async throws -> GoogleCalendarEventsDto {
        return try await api.getEvents(calendarId: calendar.data.calendarId, pageToken: pageToken, maxResults: maxResults)
    }
    func getEvents(calendar: SeesturmCalendar, timeMin: Date) async throws -> GoogleCalendarEventsDto {
        return try await api.getEvents(calendarId: calendar.data.calendarId, timeMin: timeMin)
    }
    func getEvent(calendar: SeesturmCalendar, eventId: String) async throws -> GoogleCalendarEventDto {
        return try await api.getEvent(calendarId: calendar.data.calendarId, eventId: eventId)
    }
    func getNext3Events(calendar: SeesturmCalendar) async throws -> GoogleCalendarEventsDto {
        return try await api.getEvents(calendarId: calendar.data.calendarId, includePast: false, maxResults: 3)
    }
    
}
