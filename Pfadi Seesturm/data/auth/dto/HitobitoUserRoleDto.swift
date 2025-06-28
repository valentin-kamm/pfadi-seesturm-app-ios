//
//  HitobitoUserRoleDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.05.2025.
//

struct HitobitoUserRoleDto: Decodable {
    let groupId: Int?
    let groupName: String?
    let role: String?
    let roleClass: String?
    let roleName: String?
    let permissions: [String?]?
}
