//
//  StufenbereichService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import Foundation

class StufenbereichService: WordpressService {
    
    private let anlaesseRepository: AnlaesseRepository
    private let firestoreRepository: FirestoreRepository
    private let cloudFunctionsRepository: CloudFunctionsRepository
    
    init(
        termineRepository: AnlaesseRepository,
        firestoreRepository: FirestoreRepository,
        cloudFunctionsRepository: CloudFunctionsRepository
    ) {
        self.anlaesseRepository = termineRepository
        self.firestoreRepository = firestoreRepository
        self.cloudFunctionsRepository = cloudFunctionsRepository
    }
    
    func fetchEvents(stufe: SeesturmStufe, timeMin: Date) async -> SeesturmResult<[GoogleCalendarEvent], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.anlaesseRepository.getEvents(calendar: stufe.calendar, timeMin: timeMin) },
            transform: { try $0.toGoogleCalendarEvents().items }
        )
    }
    
    func fetchEvent(stufe: SeesturmStufe, eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.anlaesseRepository.getEvent(calendar: stufe.calendar, eventId: eventId) },
            transform: { try $0.toGoogleCalendarEvent() }
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
    
    func observeAktivitaetTemplates(stufe: SeesturmStufe) -> AsyncStream<SeesturmResult<[AktivitaetTemplate], RemoteDatabaseError>> {
        return firestoreRepository.observeCollection(
            type: AktivitaetTemplateDto.self,
            collection: .aktivitaetTemplates,
            filter: { query in
                query.whereField("stufenId", isEqualTo: stufe.id)
            }
        ).map(transformAktivitaetTemplateString)
    }
    private func transformAktivitaetTemplateString(_ input: SeesturmResult<[AktivitaetTemplateDto], RemoteDatabaseError>) -> SeesturmResult<[AktivitaetTemplate], RemoteDatabaseError> {
        
        switch input {
        case .error(let e):
            return .error(e)
        case .success(let d):
            do {
                let templates = try d.map { try $0.toAktivitaetTemplate() }
                return .success(templates)
            }
            catch {
                return .error(.decodingError)
            }
        }
    }
    
    func addNewAktivitaet(
        event: CloudFunctionEventPayload,
        stufe: SeesturmStufe,
        withNotification: Bool
    ) async -> SeesturmResult<String, CloudFunctionsError> {
        
        do {
            let payload = try event.toCloudFunctionEventPayloadDto()
            let eventResponse = try await cloudFunctionsRepository.addEvent(calendar: stufe.calendar, event: payload)
            if withNotification {
                let _ = try await cloudFunctionsRepository.sendPushNotification(type: .aktivitaetNew(stufe: stufe, eventId: eventResponse.eventId))
            }
            return .success(eventResponse.eventId)
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
    
    func updateExistingAktivitaet(
        eventId: String,
        event: CloudFunctionEventPayload,
        stufe: SeesturmStufe,
        withNotification: Bool
    ) async -> SeesturmResult<String, CloudFunctionsError> {
        
        do {
            let payload = try event.toCloudFunctionEventPayloadDto()
            let response = try await cloudFunctionsRepository.updateEvent(calendar: stufe.calendar, eventId: eventId, event: payload)
            if withNotification {
                let _ = try await cloudFunctionsRepository.sendPushNotification(type: .aktivitaetUpdate(stufe: stufe, eventId: response.eventId))
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
    
    func deleteAnAbmeldungen(for aktivitaet: GoogleCalendarEventWithAnAbmeldungen) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
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
            let eventsInFuture = try await anlaesseRepository.getEvents(calendar: stufe.calendar, includePast: false, maxResults: 2500).items
            let excludedIds = eventsInFuture.map { $0.id }
            // exclude an- & abmeldungen of these events
            let abmeldungenToDelete = anAbmeldungen.filter { $0.stufe == stufe }.filter { !excludedIds.contains($0.eventId) }
            let documentsToDelete = abmeldungenToDelete.map { SeesturmFirestoreDocument.abmeldung(id: $0.id) }
            
            if !documentsToDelete.isEmpty {
                try await firestoreRepository.deleteDocuments(documents: documentsToDelete)
            }
            
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
    
    func sendPushNotification(for stufe: SeesturmStufe, for aktivitaet: GoogleCalendarEvent) async -> SeesturmResult<Void, MessagingError> {
        
        do {
            let _ = try await cloudFunctionsRepository.sendPushNotification(type: .aktivitaetGeneric(stufe: stufe, eventId: aktivitaet.id))
            return .success(())
        }
        catch {
            return .error(.unknown)
        }
    }
    
    func insertNewAktivitaetTemplate(stufe: SeesturmStufe, description: String) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        let payload = AktivitaetTemplateDto(
            stufenId: stufe.id,
            description: description
        )
        
        do {
            try await firestoreRepository.insertDocument(
                object: payload,
                collection: .aktivitaetTemplates
            )
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
    func updateAktivitaetTemplate(id: String, description: String) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        do {
            try await firestoreRepository.performTransaction(
                type: AktivitaetTemplateDto.self,
                document: .aktivitaetTemplate(id: id),
                forceNewCreatedDate: false,
                update: { oldTemplate in
                    AktivitaetTemplateDto(
                        stufenId: oldTemplate.stufenId,
                        description: description
                    )
                }
            )
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
    func deleteAktivitaetTemplates(ids: [String]) async -> SeesturmResult<Void, RemoteDatabaseError> {
        do {
            let documents = ids.map { SeesturmFirestoreDocument.aktivitaetTemplate(id: $0) }
            try await firestoreRepository.deleteDocuments(documents: documents)
            return .success(())
        }
        catch {
            return .error(.deletingError)
        }
    }
}
