//
//  DocumentsService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class DocumentsService: WordpressService {
    
    private let repository: DocumentsRepository
    
    init(repository: DocumentsRepository) {
        self.repository = repository
    }
    
    func getDocuments(type: WordpressDocumentType) async -> SeesturmResult<[WordpressDocument], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getDocuments(type: type)},
            transform: { try $0.map { try $0.toWordpressDocument() } }
        )
    }
}
