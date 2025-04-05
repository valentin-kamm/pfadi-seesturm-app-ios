//
//  LeitungsteamViewmodel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

class LeitungsteamViewModel: StateManager<UiState<[Leitungsteam]>> {
    
    private let service: LeitungsteamService
    init(
        service: LeitungsteamService
    ) {
        self.service = service
        super.init(initialState: .loading(subState: .idle))
    }
    
    func fetchLeitungsteam(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state = .loading(subState: .loading)
            }
        }
        let result = await service.getLeitungsteam()
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state = .error(message: "Leitungsteam konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state = .success(data: d)
            }
        }
    }
}
