//
//  AktivitaetDetailViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.12.2024.
//
import SwiftUI

class AktivitaetDetailViewModel: StateManager<AktivitaetDetailState> {
    
    private let service: NaechsteAktivitaetService
    let input: DetailInputType<String, GoogleCalendarEvent?>
    let stufe: SeesturmStufe
    let userId: String?
    init(
        service: NaechsteAktivitaetService,
        input: DetailInputType<String, GoogleCalendarEvent?>,
        stufe: SeesturmStufe,
        userId: String?
    ) {
        self.service = service
        self.input = input
        self.stufe = stufe
        self.userId = userId
        super.init(initialState: AktivitaetDetailState())
    }
    
    var anAbmeldenStateBinding: Binding<ActionState<AktivitaetInteraction>> {
        Binding(
            get: { self.state.anAbmeldenState },
            set: { newValue in
                self.updateState { state in
                    state.anAbmeldenState = newValue
                }
            }
        )
    }
    
    var pickerTint: Color {
        state.selectedSheetMode.color
    }
    var showSheetBinding: Binding<Bool> {
        Binding(
            get: {
                self.state.showSheet
            },
            set: { isShowing in
                self.updateState { state in
                    state.showSheet = isShowing
                }
            }
        )
    }
    var sheetModeBinding: Binding<AktivitaetInteraction> {
        Binding(
            get: { self.state.selectedSheetMode },
            set: { newValue in
                self.changeSheetMode(interaction: newValue)
            }
        )
    }
    var vornameBinding: Binding<String> {
        Binding(
            get: { self.state.vorname },
            set: { newValue in
                self.updateState { state in
                    state.vorname = newValue
                }
            }
        )
    }
    var nachnameBinding: Binding<String> {
        Binding(
            get: { self.state.nachname },
            set: { newValue in
                self.updateState { state in
                    state.nachname = newValue
                }
            }
        )
    }
    var pfadinameBinding: Binding<String> {
        Binding(
            get: { self.state.pfadiname },
            set: { newValue in
                self.updateState { state in
                    state.pfadiname = newValue
                }
            }
        )
    }
    var bemerkungBinding: Binding<String> {
        Binding(
            get: { self.state.bemerkung },
            set: { newValue in
                self.updateState { state in
                    state.bemerkung = newValue
                }
            }
        )
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
            vorname: state.vorname.trimmingCharacters(in: .whitespacesAndNewlines),
            nachname: state.nachname.trimmingCharacters(in: .whitespacesAndNewlines),
            pfadiname: state.pfadiname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : state.pfadiname.trimmingCharacters(in: .whitespacesAndNewlines),
            bemerkung: state.bemerkung.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : state.bemerkung.trimmingCharacters(in: .whitespacesAndNewlines),
            typeId: state.selectedSheetMode.id,
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
        switch input {
        case .id(let id):
            updateState { state in
                state.loadingState = .loading(subState: .loading)
            }
            let result = await service.fetchAktivitaetById(eventId: id, stufe: stufe)
            switch result {
            case .error(let e):
                switch e {
                case .cancelled:
                    updateState { state in
                        state.loadingState = .loading(subState: .retry)
                    }
                default:
                    updateState { state in
                        state.loadingState = .error(message: "Die \(stufe.aktivitaetDescription) konnte nicht geladen werden. \(e.defaultMessage)")
                    }
                }
            case .success(let d):
                updateState { state in
                    state.loadingState = .success(data: d)
                }
            }
        case .object(let object):
            updateState { state in
                state.loadingState = .success(data: object)
            }
        }
    }
    
    func sendAnAbmeldung() async {
        if !isNewAnAbmeldungOk {
            updateState { state in
                state.anAbmeldenState = .error(action: state.selectedSheetMode, message: "Die \(state.selectedSheetMode.nomen) kann nicht gespeichert werden. Die Daten sind unvollständig.")
            }
            return
        }
        updateState { state in
            state.anAbmeldenState = .loading(action: state.selectedSheetMode)
        }
        let result = await service.sendAnAbmeldung(abmeldung: newAnAbmeldung)
        switch result {
        case .error(let e):
            updateState { state in
                state.anAbmeldenState = .error(action: state.selectedSheetMode, message: "Die \(state.selectedSheetMode.nomen) kann nicht gespeichert werden. \(e.defaultMessage)")
            }
        case .success(_):
            updateState { state in
                state.showSheet = false
                state.anAbmeldenState = .success(action: state.selectedSheetMode, message: "\(state.selectedSheetMode.nomen) erfolgreich gespeichert.")
                state.vorname = ""
                state.nachname = ""
                state.pfadiname = ""
                state.bemerkung = ""
            }
        }
    }
    
    func changeSheetMode(interaction: AktivitaetInteraction) {
        updateState { state in
            state.selectedSheetMode = interaction
        }
    }
    func showSheet() {
        updateState { state in
            state.showSheet = true
        }
    }
    func insertGespeichertePerson(person: GespeichertePerson) {
        updateState { state in
            state.vorname = person.vorname
            state.nachname = person.nachname
            state.pfadiname = person.pfadiname ?? ""
        }
    }
}
