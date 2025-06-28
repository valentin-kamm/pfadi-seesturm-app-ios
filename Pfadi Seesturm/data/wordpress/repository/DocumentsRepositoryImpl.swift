//
//  DocumentsRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class DocumentsRepositoryImpl: DocumentsRepository {
    
    private let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getDocuments(type: WordpressDocumentType) async throws -> [WordpressDocumentDto] {
        return try await api.getDocuments(type: type)
    }
}
