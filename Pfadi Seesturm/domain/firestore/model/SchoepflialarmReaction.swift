//
//  SchoepflialarmReaction.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import Foundation

struct SchoepflialarmReaction: Identifiable {
    let id: String
    let created: Date
    let modified: Date
    let createdFormatted: String
    let modifiedFormatted: String
    let user: FirebaseHitobitoUser?
    let reaction: SchoepflialarmReactionType
}
