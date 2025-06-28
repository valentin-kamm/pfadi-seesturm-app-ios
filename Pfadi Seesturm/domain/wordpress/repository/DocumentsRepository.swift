//
//  WordpressDocumentRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

protocol DocumentsRepository {
    
    func getDocuments(type: WordpressDocumentType) async throws -> [WordpressDocumentDto]
}
