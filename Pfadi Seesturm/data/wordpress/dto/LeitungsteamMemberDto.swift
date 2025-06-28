//
//  LeitungsteamMemberDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.05.2025.
//
import Foundation

struct LeitungsteamMemberDto: Codable {
    let name: String
    let job: String
    let contact: String
    let photo: String
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
