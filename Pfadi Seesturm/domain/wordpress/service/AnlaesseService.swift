//
//  AnlaesseService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

class AnlaesseService: WordpressService {
    
    private let repository: AnlaesseRepository
    
    init(repository: AnlaesseRepository) {
        self.repository = repository
    }
    
    func fetchEvents(
        calendar: SeesturmCalendar,
        includePast: Bool,
        maxResults: Int
    ) async -> SeesturmResult<GoogleCalendarEvents, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getEvents(calendar: calendar, includePast: includePast, maxResults: maxResults) },
            transform: { try $0.toGoogleCalendarEvents() }
        )
    }
    
    func fetchMoreEvents(calendar: SeesturmCalendar, pageToken: String, maxResults: Int) async -> SeesturmResult<GoogleCalendarEvents, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getEvents(calendar: calendar, pageToken: pageToken, maxResults: maxResults) },
            transform: { try $0.toGoogleCalendarEvents() }
        )
    }
    
    func fetchEvent(calendar: SeesturmCalendar, eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getEvent(calendar: calendar, eventId: eventId) },
            transform: { try $0.toGoogleCalendarEvent() }
        )
    }
    
    func fetchNextThreeEvents(calendar: SeesturmCalendar) async -> SeesturmResult<GoogleCalendarEvents, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getNextThreeEvents(calendar: calendar) },
            transform: { try $0.toGoogleCalendarEvents() }
        )
    }
}
