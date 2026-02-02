//
//  UpdateCapableEventController.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.01.2026.
//

@MainActor
protocol UpdateCapableEventController: AnyObject {
    
    func fetchEvent(eventId: String) async -> SeesturmResult<GoogleCalendarEvent, NetworkError>
    func updateEvent(eventId: String, event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError>
}
