//
//  FormSection.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import Foundation

struct FormSection: Hashable, Identifiable {
    var id = UUID()
    var header: String
    var footer: String
    var order: Int
}
