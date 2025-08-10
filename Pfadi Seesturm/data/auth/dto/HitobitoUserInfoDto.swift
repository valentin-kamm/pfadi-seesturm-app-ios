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
    
    private init(
        sub: String = "",
        email: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        nickname: String? = nil,
        street: String? = nil,
        housenumber: String? = nil,
        zipCode: String? = nil,
        town: String? = nil,
        country: String? = nil,
        gender: String? = nil,
        birthday: String? = nil,
        primaryGroupId: Int? = nil,
        language: String? = nil,
        kantonalverbandId: Int? = nil,
        roles: [HitobitoUserRoleDto?]? = nil
    ) {
        self.sub = sub
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.nickname = nickname
        self.street = street
        self.housenumber = housenumber
        self.zipCode = zipCode
        self.town = town
        self.country = country
        self.gender = gender
        self.birthday = birthday
        self.primaryGroupId = primaryGroupId
        self.language = language
        self.kantonalverbandId = kantonalverbandId
        self.roles = roles
    }
}
