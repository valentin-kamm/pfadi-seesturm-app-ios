//
//  FirestoreDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.03.2025.
//
import FirebaseFirestore

protocol FirestoreDto: Codable, Identifiable {
    
    var id: String? { get }
    var created: Timestamp? { get set }
    var modified: Timestamp? { get set }
    
    func contentEquals(_ other: Self) -> Bool
}
