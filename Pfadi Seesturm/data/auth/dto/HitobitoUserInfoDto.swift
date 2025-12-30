//
//  HitobitoUserInfoDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 03.03.2025.
//

struct HitobitoUserInfoDto: Decodable {
    let sub: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let nickname: String?
    let street: String?
    let housenumber: String?
    let zipCode: String?
    let town: String?
    let country: String?
    let gender: String?
    let birthday: String?
    let primaryGroupId: Int?
    let language: String?
    let kantonalverbandId: Int?
    let roles: [HitobitoUserRoleDto?]?
}
