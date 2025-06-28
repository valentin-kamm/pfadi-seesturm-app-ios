//
//  Leitungsteam.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import Foundation

struct Leitungsteam: Identifiable {
    let id: Int
    let teamName: String
    let members: [LeitungsteamMember]
}
