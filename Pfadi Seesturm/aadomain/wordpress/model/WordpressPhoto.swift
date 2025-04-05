//
//  WordpressPhoto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.02.2025.
//
import Foundation

struct WordpressPhoto: Identifiable, Hashable {
    var id: UUID
    var thumbnail: String
    var original: String
    var orientation: String
    var height: Int
    var width: Int
}
