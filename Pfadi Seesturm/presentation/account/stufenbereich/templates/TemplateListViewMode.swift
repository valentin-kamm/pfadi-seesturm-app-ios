//
//  TemplateListViewMode.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.06.2025.
//

enum TemplateListViewMode {
    case use
    case edit(
        onAddClick: () -> Void,
        onDelete: ([AktivitaetTemplate]) -> Void,
        editState: ActionState<Void>,
        deleteState: ActionState<Void>
    )
}
