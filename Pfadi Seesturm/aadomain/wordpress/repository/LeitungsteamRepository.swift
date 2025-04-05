//
//  LeitungsteamRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//

protocol LeitungsteamRepository {
    func getLeitungsteam() async throws -> [LeitungsteamDto]
}
