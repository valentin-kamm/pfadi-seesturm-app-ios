//
//  DocumentsViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.10.2024.
//

import SwiftUI
import Observation

@Observable
@MainActor
class DocumentsViewModel {
    
    var documentsState: UiState<[WordpressDocument]> = .loading(subState: .idle)
    
    private let service: DocumentsService
    private let documentType: WordpressDocumentType
    
    init(
        service: DocumentsService,
        documentType: WordpressDocumentType
    ) {
        self.service = service
        self.documentType = documentType
    }
    
    func fetchDocuments() async {
        
        withAnimation {
            documentsState = .loading(subState: .loading)
        }
        
        let result = await service.getDocuments(type: documentType)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    documentsState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    documentsState = .error(message: "Dokumente konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                documentsState = .success(data: d)
            }
        }
    }
}

