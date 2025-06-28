//
//  GespeichertePerson.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.02.2025.
//
import Foundation

struct GespeichertePerson: Identifiable {
    
    var id: UUID
    var vorname: String
    var nachname: String
    var pfadiname: String?
}

extension GespeichertePerson {
    
    func toGespeichertePersonDao() -> GespeichertePersonDao {
        return GespeichertePersonDao(
            id: id,
            vorname: vorname,
            nachname: nachname,
            pfadiname: pfadiname
        )
    }
    
    var displayName: String {
        if let pn = pfadiname, !pn.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            "\(vorname) \(nachname) / \(pn)"
        }
        else {
            "\(vorname) \(nachname)"
        }
    }
}
