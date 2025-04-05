//
//  CloudFunctionsRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//

protocol CloudFunctionsRepository {
    
    func getFirebaseAuthToken(userId: String, hitobitoAccessToken: String) async throws -> String
    func addEvent(calendar: SeesturmCalendar, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionAddEventResponseDto
    func updateEvent(calendar: SeesturmCalendar, eventId: String, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionUpdateEventResponseDto
    func sendPushNotification() async throws
}

protocol SeesturmCloudFunction {
    associatedtype Payload: Encodable
    associatedtype Response: Decodable
    static var functionName: String { get }
}

enum SeesturmCloudFunctions {
    enum getFirebaseAuthToken: SeesturmCloudFunction {
        typealias Payload = CloudFunctionTokenRequestDto
        typealias Response = CloudFunctionTokenResponseDto
        static let functionName = "getfirebaseauthtokenv2"
    }
    enum publishGoogleCalendarEvent: SeesturmCloudFunction {
        typealias Payload = CloudFunctionAddEventRequestDto
        typealias Response = CloudFunctionAddEventResponseDto
        static let functionName = "addcalendareventv2"
    }
    enum updateGoogleCalendarEvent: SeesturmCloudFunction {
        typealias Payload = CloudFunctionUpdateEventRequestDto
        typealias Response = CloudFunctionUpdateEventResponseDto
        static let functionName = "updatecalendareventv2"
    }
}
