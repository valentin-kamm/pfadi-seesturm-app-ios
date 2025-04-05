//
//  AktivitaetBearbeitenState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.03.2025.
//
import Foundation

struct AktivitaetBearbeitenState {
    var aktivitaetState: UiState<Void>
    var publishAktivitaetState: ActionState<Void> = .idle
    var title: String = ""
    var description: String = ""
    var location: String = ""
    var start: Date
    var end: Date
    var sendPushNotification: Bool = true
    var showConfirmationDialog: Bool = false
    
    init(
        selectedSheetMode: StufenbereichSheetMode,
        initialStart: Date = DateTimeUtil.shared.nextSaturday(at: 14),
        initialEnd: Date = DateTimeUtil.shared.nextSaturday(at: 16)
    ) {
        self.start = initialStart
        self.end = initialEnd
        
        switch selectedSheetMode {
        case .hidden, .insert:
            self.aktivitaetState = .success(data: ())
        case .update(_):
            self.aktivitaetState = .loading(subState: .idle)
        }
    }
}
