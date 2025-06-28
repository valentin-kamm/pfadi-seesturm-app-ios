//
//  TemplateViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.04.2025.
//
import SwiftUI
import Observation

@Observable
@MainActor
class TemplateViewModel {
    
    var templatesState: UiState<[AktivitaetTemplate]> = .loading(subState: .idle)
    var editState: ActionState<Void> = .idle
    var deleteState: ActionState<Void> = .idle
    var showInsertSheet: Bool = false
    var editSheetTemplate: AktivitaetTemplate? = nil
    
    private let stufe: SeesturmStufe
    private let service: StufenbereichService
    
    init(
        stufe: SeesturmStufe,
        service: StufenbereichService
    ) {
        self.stufe = stufe
        self.service = service
    }
    
    var showEditSheet: Binding<Bool> {
        Binding(
            get: { self.editSheetTemplate != nil },
            set: { isShown in
                if !isShown {
                    withAnimation {
                        self.editSheetTemplate = nil
                    }
                }
            }
        )
    }
    
    func observeTemplates() async {
        
        withAnimation {
            templatesState = .loading(subState: .loading)
        }
        for await result in service.observeAktivitaetTemplates(stufe: stufe) {
            switch result {
            case .error(let e):
                withAnimation {
                    templatesState = .error(message: "Vorlagen für die \(stufe.name) konnten nicht geladen werden. \(e.defaultMessage)")
                }
            case .success(let d):
                withAnimation {
                    templatesState = .success(data: d)
                }
            }
        }
    }
    
    func deleteTemplates(_ templates: [AktivitaetTemplate]) async {
        
        withAnimation {
            deleteState = .loading(action: ())
        }
        
        let result = await service.deleteAktivitaetTemplates(ids: templates.map { $0.id })
        
        switch result {
        case .error(let e):
            withAnimation {
                deleteState = .error(action: (), message: "Vorlagen für \(stufe.name) konnte nicht gelöscht werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                deleteState = .success(action: (), message: "Vorlagen für \(stufe.name) erfolgreich gelöscht.")
            }
        }
    }
    
    func insertTemplate(description: String) async {
                
        guard !description.htmlTrimmed.isEmpty else {
            withAnimation {
                editState = .error(action: (), message: "Die Beschreibung darf nicht leer sein.")
            }
            return
        }
        
        withAnimation {
            editState = .loading(action: ())
        }
        
        let result = await service.insertNewAktivitaetTemplate(stufe: stufe, description: description.trimmingCharacters(in: .whitespacesAndNewlines))
        
        switch result {
        case .error(let e):
            withAnimation {
                editState = .error(action: (), message: "Die Vorlage konnte nicht gespeichert werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                showInsertSheet = false
                editState = .success(action: (), message: "Vorlage erfolgreich gespeichert.")
            }
        }
    }
    
    func updateTemplate(id: String, description: String) async {
                
        guard !description.htmlTrimmed.isEmpty else {
            withAnimation {
                editState = .error(action: (), message: "Die Beschreibung darf nicht leer sein.")
            }
            return
        }
        
        withAnimation {
            editState = .loading(action: ())
        }
        
        let result = await service.updateAktivitaetTemplate(id: id, description: description.trimmingCharacters(in: .whitespacesAndNewlines))
        
        switch result {
        case .error(let e):
            withAnimation {
                editState = .error(action: (), message: "Die Vorlage konnte nicht aktualisiert werden. \(e.defaultMessage)")
            }
        case .success(_):
            withAnimation {
                editSheetTemplate = nil
                editState = .success(action: (), message: "Vorlage erfolgreich aktualisiert.")
            }
        }
    }
}
