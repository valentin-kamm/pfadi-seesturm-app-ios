//
//  GespeichertePersonDao.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.02.2025.
//
import SwiftData
import Foundation

@Model
final class GespeichertePersonDao {
    
    var id: UUID
    var vorname: String
    var nachname: String
    var pfadiname: String?
    
    init(
        id: UUID,
        vorname: String,
        nachname: String,
        pfadiname: String?
    ) {
        self.id = id
        self.vorname = vorname
        self.nachname = nachname
        self.pfadiname = pfadiname
    }
}

extension GespeichertePersonDao {
    func toGespeichertePerson() -> GespeichertePerson {
        return GespeichertePerson(
            id: id,
            vorname: vorname,
            nachname: nachname,
            pfadiname: pfadiname
        )
    }
}
