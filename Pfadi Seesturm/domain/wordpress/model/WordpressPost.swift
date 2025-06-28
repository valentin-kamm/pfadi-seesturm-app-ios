//
//  WordpressPost.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import Foundation

struct WordpressPost: Identifiable, Hashable {
    var id: Int
    var publishedYear: String
    var publishedFormatted: String
    var modifiedFormatted: String
    var imageUrl: String
    var title: String
    var titleDecoded: String
    var content: String
    var contentPlain: String
    var imageAspectRatio: Double
    var author: String
}

extension [WordpressPost] {
    var groupedByYear: [(String, [WordpressPost])] {
        let grouped = Dictionary(grouping: self, by: { $0.publishedYear })
        let sortedKeys = grouped.keys.sorted(by: >)
        return sortedKeys.map { year in
            (year, grouped[year] ?? [])
        }
    }
}
