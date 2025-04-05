//
//  GespeichertePersonenState.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.02.2025.
//

struct GespeichertePersonenState {
    var addingState: UiState<Void> = .success(data: ())
    var deletingState: [UiState<Void>] = []
    var showInsertSheet: Bool = false
    var vorname: String = ""
    var nachname: String = ""
    var pfadiname: String = ""
}
