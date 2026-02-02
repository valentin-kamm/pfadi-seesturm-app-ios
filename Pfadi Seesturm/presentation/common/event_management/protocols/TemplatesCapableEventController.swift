//
//  TemplatesCapableEventController.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.01.2026.
//

@MainActor
protocol TemplatesCapableEventController: AnyObject {
    
    var templatesState: UiState<[AktivitaetTemplate]> { get set }
    var showTemplatesSheet: Bool { get set }
    func observeTemplates() async
}
