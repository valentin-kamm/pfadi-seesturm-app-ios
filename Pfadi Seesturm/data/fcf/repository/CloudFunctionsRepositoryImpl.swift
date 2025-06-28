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
    
    func getFirebaseAuthToken(userId: String, hitobitoAccessToken: HitobitoAccessToken) async throws -> FirebaseAuthToken {
        
        let payload = CloudFunctionTokenRequestDto(
            userId: userId,
            hitobitoAccessToken: hitobitoAccessToken
        )
        let response = try await api.invokeCloudFunction(function: SeesturmCloudFunctions.getFirebaseAuthToken.self, input: payload)
        if response.userId != userId {
            throw PfadiSeesturmError.authError(message: "Ungültige Benutzer-ID im Authentifizierungs-Token.")
        }
        if response.firebaseAuthToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw PfadiSeesturmError.authError(message: "Authentifizierungs-Token ist leer.")
        }
        return response.firebaseAuthToken
    }
    
    func addEvent(calendar: SeesturmCalendar, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionAddEventResponseDto {
        let payload = CloudFunctionAddEventRequestDto(
            calendarId: calendar.data.calendarId,
            payload: event
        )
        return try await api.invokeCloudFunction(function: SeesturmCloudFunctions.publishGoogleCalendarEvent.self, input: payload)
    }
    
    func updateEvent(calendar: SeesturmCalendar, eventId: String, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionUpdateEventResponseDto {
        let payload = CloudFunctionUpdateEventRequestDto(
            calendarId: calendar.data.calendarId,
            eventId: eventId,
            payload: event
        )
        return try await api.invokeCloudFunction(function: SeesturmCloudFunctions.updateGoogleCalendarEvent.self, input: payload)
    }
    
    func sendPushNotification(type: SeesturmFCMNotificationType) async throws -> CloudFunctionPushNotificationResponseDto {
        
        let payload = CloudFunctionPushNotificationRequestDto(
            topic: type.topic.rawValue,
            title: type.content.title,
            body: type.content.body,
            customKey: type.content.customKey
        )
        return try await api.invokeCloudFunction(function: SeesturmCloudFunctions.sendPushNotificationToTopic.self, input: payload)
    }
}
