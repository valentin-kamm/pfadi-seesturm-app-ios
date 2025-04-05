//
//  Leitungsteam.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import Foundation

struct Leitungsteam: Identifiable {
    let id: UUID
    let teamName: String
    let teamId: Int
    let members: [LeitungsteamMember]
}
struct LeitungsteamMember: Identifiable {
    let id: UUID
    let name: String
    let job: String
    let contact: String
    let photo: String
}
