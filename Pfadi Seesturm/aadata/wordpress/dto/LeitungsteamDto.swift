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
struct LeitungsteamMemberDto: Codable {
    let name: String
    let job: String
    let contact: String
    let photo: String
}

extension LeitungsteamDto {
    func toLeitungsteam() -> Leitungsteam {
        return Leitungsteam(
            id: UUID(),
            teamName: teamName,
            teamId: teamId,
            members: members.map { $0.toLeitungsteamMember() }
        )
    }
}
extension LeitungsteamMemberDto {
    func toLeitungsteamMember() -> LeitungsteamMember {
        return LeitungsteamMember(
            id: UUID(),
            name: name,
            job: job,
            contact: contact,
            photo: photo
        )
    }
}
