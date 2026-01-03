//
//  WordpressDocument.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import SwiftUI

struct WordpressDocument: Identifiable {
    var id: String
    var thumbnailUrl: String
    var thumbnailWidth: Int
    var thumbnailHeight: Int
    var title: String
    var documentUrl: String
    var published: Date
    var publishedFormatted: String
}
