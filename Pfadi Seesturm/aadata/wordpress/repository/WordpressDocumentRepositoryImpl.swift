//
//  WordpressDocumentRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class WordpressDocumentRepositoryImpl: WordpressDocumentRepository {
    
    let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getDocuments() async throws -> [WordpressDocumentDto] {
        return try await api.getDocuments()
    }
    func getLuuchtturm() async throws -> [WordpressDocumentDto] {
        return try await api.getLuuchtturm()
    }
}
