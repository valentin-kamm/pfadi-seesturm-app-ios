//
//  HitobitoUserInfoDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 03.03.2025.
//

struct HitobitoUserRoleDto: Decodable {
    let groupId: Int?
    let groupName: String?
    let role: String?
    let roleClass: String?
    let roleName: String?
    let permissions: [String?]?
}

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

extension HitobitoUserInfoDto {
    func toFirebaseHitobitoUserDto() -> FirebaseHitobitoUserDto {
        return FirebaseHitobitoUserDto(
            id: sub,
            email: email,
            firstName: firstName,
            lastName: lastName,
            pfadiName: nickname
        )
    }
}


/*
 {
     "sub": "23455",
     "email": "valentinkamm@gmail.com",
     "first_name": "Valentin",
     "last_name": "Kamm",
     "nickname": "Pancho",
     "address": "Sonnenring 3A",
     "address_care_of": null,
     "street": "Sonnenring",
     "housenumber": "3A",
     "postbox": null,
     "zip_code": "8590",
     "town": "Romanshorn",
     "country": "CH",
     "company_name": null,
     "company": false,
     "gender": "m",
     "birthday": "1997-07-25",
     "primary_group_id": 1244,
     "title": null,
     "salutation": "lieber_pfadiname",
     "language": "de",
     "prefers_digital_correspondence": false,
     "kantonalverband_id": 993,
     "roles": [
         {
             "group_id": 1244,
             "group_name": "Seesturm Neukirch-Egnach",
             "role": "Group::Abteilung::Adressverwaltung",
             "role_class": "Group::Abteilung::Adressverwaltung",
             "role_name": "Adressverwalter*in",
             "permissions": [
                 "layer_full"
             ]
         },
         {
             "group_id": 1753,
             "group_name": "0 - Biberstufe",
             "role": "Group::Biber::Mitleitung",
             "role_class": "Group::Biber::Mitleitung",
             "role_name": "Mitleiter*in",
             "permissions": [
                 "layer_and_below_read"
             ]
         },
         {
             "group_id": 1758,
             "group_name": "4 - Roverstufe",
             "role": "Group::AbteilungsGremium::Mitglied",
             "role_class": "Group::AbteilungsGremium::Mitglied",
             "role_name": "Mitglied",
             "permissions": [
                 "group_read"
             ]
         },
         {
             "group_id": 9973,
             "group_name": "OK PFF 2023",
             "role": "Group::KantonalesGremium::Mitglied",
             "role_class": "Group::KantonalesGremium::Mitglied",
             "role_name": "Mitglied",
             "permissions": [
                 "group_read"
             ]
         }
     ]
 }
 */
