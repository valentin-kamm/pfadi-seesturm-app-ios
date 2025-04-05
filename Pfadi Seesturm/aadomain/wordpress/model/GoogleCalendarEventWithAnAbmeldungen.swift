//
//  GoogleCalendarEventWithAnAbmeldungen.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 25.03.2025.
//
import SwiftUI

struct GoogleCalendarEventWithAnAbmeldungen: Hashable {
    var event: GoogleCalendarEvent
    var anAbmeldungen: [AktivitaetAnAbmeldung]
}

extension GoogleCalendarEventWithAnAbmeldungen {
    func displayTextAnAbmeldungen(interaction: AktivitaetInteraction) -> String {
        let count = anAbmeldungen.count { $0.type == interaction }
        if count == 1 {
            return "\(count) \(interaction.nomen)"
        }
        else {
            return "\(count) \(interaction.nomenMehrzahl)"
        }
    }
}
