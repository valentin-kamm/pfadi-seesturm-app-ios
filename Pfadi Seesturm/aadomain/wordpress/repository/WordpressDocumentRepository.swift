//
//  WordpressDocumentRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

protocol WordpressDocumentRepository {
    func getDocuments() async throws -> [WordpressDocumentDto]
    func getLuuchtturm() async throws -> [WordpressDocumentDto]
}
