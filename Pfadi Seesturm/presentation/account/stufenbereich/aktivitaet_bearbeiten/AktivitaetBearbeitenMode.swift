//
//  AktivitaetBearbeitenMode.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.06.2025.
//

enum AktivitaetBearbeitenMode: Hashable {
    
    case update(id: String)
    case insert
    
    var verb: String {
        switch self {
        case .insert:
            "veröffentlichen"
        case .update(_):
            "aktualisieren"
        }
    }
    var verbPassiv: String {
        switch self {
        case .insert:
            "veröffentlicht"
        case .update(_):
            "aktualisiert"
        }
    }
    var buttonTitle: String {
        switch self {
        case .insert:
            "Veröffentlichen"
        case .update(_):
            "Aktualisieren"
        }
    }
    func navigationTitle(for stufe: SeesturmStufe) -> String {
        switch self {
        case .insert:
            "Neue \(stufe.aktivitaetDescription)"
        case .update(_):
            "\(stufe.aktivitaetDescription) bearbeiten"
        }
    }
}
