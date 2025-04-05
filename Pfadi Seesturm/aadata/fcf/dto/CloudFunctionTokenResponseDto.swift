//
//  CloudFunctionTokenResponseDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//

struct CloudFunctionTokenResponseDto: Codable {
    let userId: String
    let firebaseToken: String
}
