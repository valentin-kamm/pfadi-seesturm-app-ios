//
//  TemplateEditMode.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.06.2025.
//

enum TemplateEditMode {
    case insert(onSubmit: (String) -> Void)
    case update(
        description: String,
        onSubmit: (String) -> Void
    )
    
    var buttonTitle: String {
        switch self {
        case .insert(_):
            return "Speichern"
        case .update:
            return "Aktualisieren"
        }
    }
    var navigationTitle: String {
        switch self {
        case .insert(_):
            "Neue Vorlage"
        case .update(_, _):
            "Vorlage bearbeiten"
        }
    }
}
