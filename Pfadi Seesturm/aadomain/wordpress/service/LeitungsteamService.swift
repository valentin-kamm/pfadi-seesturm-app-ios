//
//  LeitungsteamService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

class LeitungsteamService: WordpressService {
    
    let repository: LeitungsteamRepository
    init(repository: LeitungsteamRepository) {
        self.repository = repository
    }
    
    func getLeitungsteam() async -> SeesturmResult<[Leitungsteam], NetworkError> {
        await fetchFromWordpress(
            fetchAction: { try await self.repository.getLeitungsteam() },
            transform: { $0.map { $0.toLeitungsteam() } }
        )
    }
}
