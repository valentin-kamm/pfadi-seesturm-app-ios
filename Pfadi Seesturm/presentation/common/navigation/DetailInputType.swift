//
//  DetailInputType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.03.2025.
//

enum DetailInputType<Id: Hashable, Object: Hashable>: Hashable {
    case id(id: Id)
    case object(object: Object)
}
