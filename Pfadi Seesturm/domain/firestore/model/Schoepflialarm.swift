//
//  Schoepflialarm.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import Foundation

struct Schoepflialarm: Hashable {
    let id: String
    let created: Date
    let modified: Date
    let createdFormatted: String
    let modifiedFormatted: String
    let message: String
    let user: FirebaseHitobitoUser?
    let reactions: [SchoepflialarmReaction]
}

extension Schoepflialarm {
    
    func reactionCount(for reaction: SchoepflialarmReactionType) -> Int {
        return self.reactions.filter { $0.reaction == reaction }.count
    }
    func reactions(for reaction: SchoepflialarmReactionType) -> [SchoepflialarmReaction] {
        return self.reactions.filter { $0.reaction == reaction }.sorted { $0.created > $1.created }
    }
}
