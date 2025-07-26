//
//  LeitungsteamViewmodel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class LeitungsteamViewModel {
    
    var leitungsteamState: UiState<[Leitungsteam]> = .loading(subState: .idle)
    
    private let service: LeitungsteamService
    
    init(
        service: LeitungsteamService
    ) {
        self.service = service
    }
    
    func fetchLeitungsteam() async {
        
        withAnimation {
            leitungsteamState = .loading(subState: .loading)
        }
        
        let result = await service.getLeitungsteam()
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    leitungsteamState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    leitungsteamState = .error(message: "Leitungsteam konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                leitungsteamState = .success(data: d)
            }
        }
    }
}
