//
//  NaechsteAktivitaetRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.02.2025.
//

protocol NaechsteAktivitaetRepository {
    func fetchNaechsteAktivitaet(stufe: SeesturmStufe) async throws -> GoogleCalendarEventsDto
    func fetchAktivitaetById(eventId: String, stufe: SeesturmStufe) async throws -> GoogleCalendarEventDto
}
