//
//  CloudFunctionEventPayload.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.03.2025.
//

struct CloudFunctionEventPayloadDto: Codable {
    let summary: String?
    let description: String?
    let location: String?
    let start: GoogleCalendarEventStartEndDto
    let end: GoogleCalendarEventStartEndDto
}
