//
//  AktivitaetDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//
import SwiftUI
import Observation

@Observable
@MainActor
class AktivitaetDetailViewModel {
    
    var loadingState: UiState<GoogleCalendarEvent?>
    var anAbmeldenState: ActionState<AktivitaetInteractionType> = .idle
    var showSheet: Bool = false
    var selectedSheetMode: AktivitaetInteractionType = .abmelden
    var vorname: String = ""
    var nachname: String = ""
    var pfadiname: String = ""
    var bemerkung = ""
    
    private let service: NaechsteAktivitaetService
    private let input: DetailInputType<String, GoogleCalendarEvent?>
    private let stufe: SeesturmStufe
    private let userId: String?
    
    init(
        input: DetailInputType<String, GoogleCalendarEvent?>,
        service: NaechsteAktivitaetService,
        stufe: SeesturmStufe,
        userId: String?
    ) {
        self.input = input
        self.service = service
        self.stufe = stufe
        self.userId = userId
        
        switch input {
        case .id(_):
            self.loadingState = .loading(subState: .idle)
        case .object(let object):
            self.loadingState = .success(data: object)
        }
    }
    
    private var currentEventId: String {
        switch input {
        case .id(let id):
            return id
        case .object(let object):
            return object?.id ?? ""
        }
    }
    
    private var newAnAbmeldung: AktivitaetAnAbmeldungDto {
        AktivitaetAnAbmeldungDto(
            eventId: currentEventId,
            uid: userId,
            vorname: vorname.trimmingCharacters(in: .whitespacesAndNewlines),
            nachname: nachname.trimmingCharacters(in: .whitespacesAndNewlines),
            pfadiname: pfadiname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : pfadiname.trimmingCharacters(in: .whitespacesAndNewlines),
            bemerkung: bemerkung.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : bemerkung.trimmingCharacters(in: .whitespacesAndNewlines),
            typeId: selectedSheetMode.id,
            stufenId: stufe.id
        )
    }
    
    private var isNewAnAbmeldungOk: Bool {
        if newAnAbmeldung.vorname.isEmpty || newAnAbmeldung.nachname.isEmpty {
            return false
        }
        return true
    }
    
    func getAktivitaet() async {
        
        guard case .id(let id) = input else {
            return
        }
            
        withAnimation {
            loadingState = .loading(subState: .loading)
        }
        let result = await service.fetchAktivitaetById(eventId: id, stufe: stufe)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    loadingState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    loadingState = .error(message: "Die \(stufe.aktivitaetDescription) konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                loadingState = .success(data: d)
            }
        }
    }
    
    func sendAnAbmeldung() async {
        
        guard isNewAnAbmeldungOk else {
            withAnimation {
                anAbmeldenState = .error(action: selectedSheetMode, message: "Die \(selectedSheetMode.nomen) kann nicht gespeichert werden. Die Daten sind unvollständig.")
            }
            return
        }
        
        withAnimation {
            anAbmeldenState = .loading(action: selectedSheetMode)
        }
        
        let result = await service.sendAnAbmeldung(abmeldung: newAnAbmeldung)
        
        switch result {
        case .error(let e):
            withAnimation {
                anAbmeldenState = .error(action: selectedSheetMode, message: "Die \(selectedSheetMode.nomen) kann nicht gespeichert werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                showSheet = false
                anAbmeldenState = .success(action: selectedSheetMode, message: "\(selectedSheetMode.nomen) erfolgreich gespeichert.")
                vorname = ""
                nachname = ""
                pfadiname = ""
                bemerkung = ""
            }
        }
    }
    
    func useGespeichertePerson(person: GespeichertePerson) {
        withAnimation {
            vorname = person.vorname
            nachname = person.nachname
            pfadiname = person.pfadiname ?? ""
        }
    }
}
