//
//  NaechsteAktivitaetService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.02.2025.
//
import Foundation
import SwiftData

class NaechsteAktivitaetService: WordpressService {
    
    let repository: NaechsteAktivitaetRepository
    let firestoreRepository: FirestoreRepository
    init(
        repository: NaechsteAktivitaetRepository,
        firestoreRepository: FirestoreRepository
    ) {
        self.repository = repository
        self.firestoreRepository = firestoreRepository
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
    
    func fetchNaechsteAktivitaet(stufe: SeesturmStufe) async -> SeesturmResult<GoogleCalendarEvent?, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.fetchNaechsteAktivitaet(stufe: stufe)},
            transform: { try $0.toGoogleCalendarEvents().items.first }
        )
    }
    
    func fetchAktivitaetById(eventId: String, stufe: SeesturmStufe) async -> SeesturmResult<GoogleCalendarEvent, NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.fetchAktivitaetById(eventId: eventId, stufe: stufe) },
            transform: { try $0.toGoogleCalendarEvent() }
        )
    }
    
    func readSelectedStufen(modelContext: ModelContext) -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
        let descriptor = FetchDescriptor<SelectedStufeDao>()
        do {
            let daoArray = try modelContext.fetch(descriptor)
            let stufenArray = try daoArray.map { try $0.getStufe() }
            return .success(Set(stufenArray))
        }
        catch {
            return .error(.readingError)
        }
    }
    func deleteStufe(stufe: SeesturmStufe, modelContext: ModelContext) -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
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
            let newStufen = readSelectedStufen(modelContext: modelContext)
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
    func addStufe(stufe: SeesturmStufe, modelContext: ModelContext) -> SeesturmResult<Set<SeesturmStufe>, LocalError> {
        do {
            modelContext.insert(SelectedStufeDao(stufe: stufe))
            try modelContext.save()
            let newStufen = readSelectedStufen(modelContext: modelContext)
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
