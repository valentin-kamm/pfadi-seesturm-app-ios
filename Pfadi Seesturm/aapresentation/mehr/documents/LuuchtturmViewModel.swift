//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class LuuchtturmViewModel: StateManager<UiState<[WordpressDocument]>> {
    
    private let service: WordpressDocumentsService
    init(
        service: WordpressDocumentsService
    ) {
        self.service = service
        super.init(initialState: .loading(subState: .idle))
    }
    
    // function to fetch the desired posts (downloads) using the network manager
    func fetchDocuments() async {
        
        updateState { state in
            state = .loading(subState: .loading)
        }
        let result = await service.getLuuchtturm()
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state = .error(message: "Dokumente konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state = .success(data: d)
            }
        }
    }
}
