//
//  CloudFunctionsRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//
import Foundation

class CloudFunctionsRepositoryImpl: CloudFunctionsRepository {
        
    private let api: CloudFunctionsApi
    init(api: CloudFunctionsApi) {
        self.api = api
    }
    
    func getFirebaseAuthToken(userId: String, hitobitoAccessToken: String) async throws -> String {
        let payload = CloudFunctionTokenRequestDto(
            userId: userId,
            hitobitoAccessToken: hitobitoAccessToken
        )
        let response = try await invokeCloudFunction(function: SeesturmCloudFunctions.getFirebaseAuthToken.self, input: payload)
        if response.userId != userId {
            throw PfadiSeesturmError.authError(message: "Ungültige Benutzer-ID im Authentifizierungs-Token.")
        }
        if response.firebaseToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw PfadiSeesturmError.authError(message: "Authentifizierungs-Token ist leer.")
        }
        return response.firebaseToken
    }
    
    func addEvent(calendar: SeesturmCalendar, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionAddEventResponseDto {
        let payload = CloudFunctionAddEventRequestDto(
            calendarId: calendar.data.calendarId,
            payload: event
        )
        return try await invokeCloudFunction(function: SeesturmCloudFunctions.publishGoogleCalendarEvent.self, input: payload)
    }
    
    func updateEvent(calendar: SeesturmCalendar, eventId: String, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionUpdateEventResponseDto {
        let payload = CloudFunctionUpdateEventRequestDto(
            calendarId: calendar.data.calendarId,
            eventId: eventId,
            payload: event
        )
        return try await invokeCloudFunction(function: SeesturmCloudFunctions.updateGoogleCalendarEvent.self, input: payload)
    }
    
    func sendPushNotification() async throws {
        throw NSError(domain: "", code: 0, userInfo: ["info": "Noch nicht implementiert."])
    }
    
    private func invokeCloudFunction<F: SeesturmCloudFunction>(function: F.Type, input: F.Payload) async throws -> F.Response {
        return try await api.invokeCloudFunction(name: F.functionName, data: input)
    }
}
