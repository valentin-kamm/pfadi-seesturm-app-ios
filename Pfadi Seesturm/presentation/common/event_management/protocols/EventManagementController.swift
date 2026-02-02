//
//  EventManagementController.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.01.2026.
//

@MainActor
protocol EventManagementController: AnyObject {
    
    var eventPreviewType: EventPreviewType { get }
    func validateEvent(event: CloudFunctionEventPayload, isAllDay: Bool, trimmedDescription: String, mode: EventManagementMode) -> EventValidationStatus
    func addEvent(event: CloudFunctionEventPayload) async -> SeesturmResult<Void, CloudFunctionsError>
}
