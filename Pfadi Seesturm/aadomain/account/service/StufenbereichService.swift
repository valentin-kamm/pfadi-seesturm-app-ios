//
//  StufenbereichService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import Foundation

class StufenbereichService: WordpressService {
    
    private let termineRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    
    init(
        termineRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository,
        cloudFunctionsRepository: CloudFunctionsRepository
    ) {
        self.termineRepository = termineRepository
        self.firestoreRepository = firestoreRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
    }
    
    func addNewAktivitaet(event: CloudFunctionEventPayload, stufe: SeesturmStufe, withNotification: Bool) async -> SeesturmResult<String, CloudFunctionsError> {
        
        do {
            let payload = try event.toCloudFunctionEventPayloadDto()
            let response = try await cloudFunctionsRepository.addEvent(calendar: stufe.calendar, event: payload)
            if withNotification {
                try await cloudFunctionsRepository.sendPushNotification()
            }
            return .success(response.eventId)
        }
        catch _ as EncodingError {
            return .error(.invalidPayload)
        }
        catch _ as DecodingError {
            return .error(.invalidResponse)
        }
        catch {
            return .error(.unknown(message: error.localizedDescription))
        }
    }
    
    func updateExistingAktivitaet(eventId: String, event: CloudFunctionEventPayload, stufe: SeesturmStufe, withNotification: Bool) async -> SeesturmResult<String, CloudFunctionsError> {
        
        do {
            let payload = try event.toCloudFunctionEventPayloadDto()
            let response = try await cloudFunctionsRepository.updateEvent(calendar: stufe.calendar, eventId: eventId, event: payload)
            if withNotification {
                try await cloudFunctionsRepository.sendPushNotification()
            }
            return .success(response.eventId)
        }
        catch _ as EncodingError {
            return .error(.invalidPayload)
        }
        catch _ as DecodingError {
            return .error(.invalidResponse)
        }
        catch {
            return .error(.unknown(message: error.localizedDescription))
        }
    }
    
    func fetchEvent(stufe: SeesturmStufe, eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.termineRepository.getEvent(calendar: stufe.calendar, eventId: eventId) },
            transform: { try $0.toGoogleCalendarEvent() }
        )
    }
    
    func deleteAnAbmeldungen(aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        let documents = aktivitaet.anAbmeldungen.map { SeesturmFirestoreDocument.abmeldung(id: $0.id) }
        
        do {
            if !documents.isEmpty {
                try await firestoreRepository.deleteDocuments(documents: documents)
            }
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    
    func deleteAllPastAnAbmeldungen(stufe: SeesturmStufe, anAbmeldungen: [AktivitaetAnAbmeldung]) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        do {
            // get all events that lie in the future
            let eventsInFuture = try await termineRepository.getEvents(calendar: stufe.calendar, includePast: false, maxResults: 2500).items
            let excludedIds = eventsInFuture.map { $0.id }
            // exclude anAbmeldungen of these events
            let abmeldungenToDelete = anAbmeldungen.filter { $0.stufe == stufe }.filter { !excludedIds.contains($0.eventId) }
            let documentsToDelete = abmeldungenToDelete.map { SeesturmFirestoreDocument.abmeldung(id: $0.id) }
            
            if documentsToDelete.isEmpty {
                return .success(())
            }
            
            try await firestoreRepository.deleteDocuments(documents: documentsToDelete)
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    
    func sendPushNotification(stufe: SeesturmStufe, aktivitaet: GoogleCalendarEvent) async -> SeesturmResult<Void, MessagingError> {
        
        do {
            try await cloudFunctionsRepository.sendPushNotification()
            return .success(())
        }
        catch {
            return .error(.unknown)
        }
    }
    
    func fetchEvents(stufe: SeesturmStufe, timeMin: Date) async -> SeesturmResult<[GoogleCalendarEvent], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.termineRepository.getEvents(calendar: stufe.calendar, timeMin: timeMin) },
            transform: { try $0.toGoogleCalendarEvents().items }
        )
    }
    
    func observeAnAbmeldungen(stufe: SeesturmStufe) -> AsyncStream<SeesturmResult<[AktivitaetAnAbmeldung], RemoteDatabaseError>> {
        return firestoreRepository.observeCollection(
            type: AktivitaetAnAbmeldungDto.self,
            collection: .abmeldungen,
            filter: { query in
                query.whereField("stufenId", isEqualTo: stufe.id)
            }
        ).map(transformAnAbmeldungenStream)
    }
    
    private func transformAnAbmeldungenStream(_ input: SeesturmResult<[AktivitaetAnAbmeldungDto], RemoteDatabaseError>) -> SeesturmResult<[AktivitaetAnAbmeldung], RemoteDatabaseError> {
        switch input {
        case .error(let e):
            return .error(e)
        case .success(let d):
            do {
                let abmeldungen = try d.map{ try $0.toAktivitaetAnAbmeldung()}
                return .success(abmeldungen)
            }
            catch {
                return .error(.decodingError)
            }
        }
    }
}
