//
//  NaechsteAktivitaetService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.02.2025.
//
import Foundation
import SwiftData

class NaechsteAktivitaetService: WordpressService {
    
    private let repository: NaechsteAktivitaetRepository
    private let firestoreRepository: FirestoreRepository
    private let modelContext: ModelContext
    
    init(
        repository: NaechsteAktivitaetRepository,
        firestoreRepository: FirestoreRepository,
        modelContext: ModelContext
    ) {
        self.repository = repository
        self.firestoreRepository = firestoreRepository
        self.modelContext = modelContext
    }
    
    func sendAnAbmeldung(abmeldung: AktivitaetAnAbmeldungDto) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        do {
            try await firestoreRepository.insertDocument(object: abmeldung, collection: .abmeldungen)
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
    
    func fetchNaechsteAktivitaet(for stufe: SeesturmStufe) async -> SeesturmResult<GoogleCalendarEvent?, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.fetchNaechsteAktivitaet(stufe: stufe)},
            transform: { try $0.toGoogleCalendarEvents().items.first }
        )
    }
    
    func fetchAktivitaetById(eventId: String, stufe: SeesturmStufe) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.fetchAktivitaetById(stufe: stufe, eventId: eventId) },
            transform: { try $0.toGoogleCalendarEvent() }
        )
    }
    
    func readSelectedStufen() -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
        
        let descriptor = FetchDescriptor<SelectedStufeDao>()
        do {
            let stufenArray = try modelContext.fetch(descriptor).map { try $0.getStufe() }
            return .success(Set(stufenArray))
        }
        catch {
            return .error(.readingError)
        }
    }
    
    func deleteStufe(stufe: SeesturmStufe) -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
        do {
            let descriptor = FetchDescriptor<SelectedStufeDao>(
                predicate: SelectedStufeDao.stufeFilter(stufe: stufe)
            )
            let daoToDelete = try modelContext.fetch(descriptor)
            if !daoToDelete.isEmpty {
                for dao in daoToDelete {
                    modelContext.delete(dao)
                }
                try modelContext.save()
            }
            let newStufen = readSelectedStufen()
            switch newStufen {
            case .error(_):
                return .error(.deletingError)
            case .success(let d):
                return .success(d)
            }
        }
        catch {
            return .error(.deletingError)
        }
    }
    
    func addStufe(stufe: SeesturmStufe) -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
        do {
            modelContext.insert(SelectedStufeDao(stufe: stufe))
            try modelContext.save()
            let newStufen = readSelectedStufen()
            switch newStufen {
            case .error(_):
                return .error(.savingError)
            case .success(let d):
                return .success(d)
            }
        }
        catch {
            return .error(.savingError)
        }
    }
}
