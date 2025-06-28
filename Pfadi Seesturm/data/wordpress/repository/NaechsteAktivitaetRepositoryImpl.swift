//
//  NaechsteAktivitaetRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.02.2025.
//

class NaechsteAktivitaetRepositoryImpl: NaechsteAktivitaetRepository {
    
    private let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func fetchNaechsteAktivitaet(stufe: SeesturmStufe) async throws -> GoogleCalendarEventsDto {
        return try await api.getEvents(calendarId: stufe.calendar.data.calendarId, includePast: false, maxResults: 1)
    }
    
    func fetchAktivitaetById(stufe: SeesturmStufe, eventId: String) async throws -> GoogleCalendarEventDto {
        return try await api.getEvent(calendarId: stufe.calendar.data.calendarId, eventId: eventId)
    }
}
