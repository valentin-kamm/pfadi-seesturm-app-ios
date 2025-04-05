//
//  CloudFunctionUpdateEventRequestDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.03.2025.
//

struct CloudFunctionUpdateEventRequestDto: Encodable {
    let calendarId: String
    let eventId: String
    let payload: CloudFunctionEventPayloadDto
}
