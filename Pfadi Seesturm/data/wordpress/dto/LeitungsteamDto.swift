//
//  LeitungsteamDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import Foundation

struct LeitungsteamDto: Codable {
    let teamName: String
    let teamId: Int
    let members: [LeitungsteamMemberDto]
}

extension LeitungsteamDto {
    func toLeitungsteam() -> Leitungsteam {
        return Leitungsteam(
            id: teamId,
            teamName: teamName,
            members: members.map { $0.toLeitungsteamMember() }
        )
    }
}
