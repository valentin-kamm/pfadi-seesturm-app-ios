//
//  AktivitaetTemplate.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.04.2025.
//
import Foundation

struct AktivitaetTemplate: Identifiable {
    let id: String
    let created: Date
    let modified: Date
    let stufe: SeesturmStufe
    let description: String
}
