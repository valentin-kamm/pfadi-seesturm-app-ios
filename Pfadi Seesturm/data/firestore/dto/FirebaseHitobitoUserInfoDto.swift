//
//  FirebaseHitobitoUserInfoDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.12.2025.
//
import FirebaseFirestore
import Foundation

struct FirebaseHitobitoUserInfoDto: FirestoreDto {
    @DocumentID var id: String?
    @ServerTimestamp var created: Timestamp?
    @ServerTimestamp var modified: Timestamp?
    var email: String?
    var firstname: String?
    var lastname: String?
    var pfadiname: String?
    var role: String
    
    func contentEquals(_ other: FirebaseHitobitoUserInfoDto) -> Bool {
        return id == other.id &&
        email == other.email &&
        firstname == other.firstname &&
        lastname == other.lastname &&
        pfadiname == other.pfadiname &&
        role == other.role
    }
    
    init(_ dto: HitobitoUserInfoDto, role: String) {
        self.id = dto.sub
        self.created = nil
        self.modified = nil
        self.email = dto.email
        self.firstname = dto.firstName
        self.lastname = dto.lastName
        self.pfadiname = dto.nickname
        self.role = role
    }
}
