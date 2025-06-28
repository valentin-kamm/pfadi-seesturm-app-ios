//
//  CloudFunctionAddEventDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.03.2025.
//

struct CloudFunctionAddEventRequestDto: Encodable {
    let calendarId: String
    let payload: CloudFunctionEventPayloadDto
}
