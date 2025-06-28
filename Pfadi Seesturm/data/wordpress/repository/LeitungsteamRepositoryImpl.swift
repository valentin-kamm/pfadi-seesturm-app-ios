//
//  LeitungsteamRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class LeitungsteamRepositoryImpl: LeitungsteamRepository {
    
    private let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getLeitungsteam() async throws -> [LeitungsteamDto] {
        return try await api.getLeitungsteam()
    }
}
