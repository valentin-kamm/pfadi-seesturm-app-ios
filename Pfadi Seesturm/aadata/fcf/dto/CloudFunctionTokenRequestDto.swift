//
//  CloudFunctionTokenInput.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//

struct CloudFunctionTokenRequestDto: Codable {
    let userId: String
    let hitobitoAccessToken: String
}
