//
//  CloudFunctionPushNotificationRequestDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.04.2025.
//

struct CloudFunctionPushNotificationRequestDto: Codable {
    let topic: String
    let title: String
    let body: String
    let customKey: String?
}
