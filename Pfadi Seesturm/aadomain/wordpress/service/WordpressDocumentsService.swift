//
//  WordpressDocumentsService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class WordpressDocumentsService: WordpressService {
    
    let repository: WordpressDocumentRepository
    init(repository: WordpressDocumentRepository) {
        self.repository = repository
    }
    
    func getDocuments() async -> SeesturmResult<[WordpressDocument], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getDocuments() },
            transform: { try $0.map { try $0.toWordpressDocument() } }
        )
    }
    func getLuuchtturm() async -> SeesturmResult<[WordpressDocument], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getLuuchtturm() },
            transform: { try $0.map { try $0.toWordpressDocument() } }
        )
    }
}
