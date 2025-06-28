//
//  CloudFunctionsRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 05.03.2025.
//
import SwiftUI

protocol CloudFunctionsRepository {
    
    func getFirebaseAuthToken(userId: String, hitobitoAccessToken: HitobitoAccessToken) async throws -> FirebaseAuthToken
    func addEvent(calendar: SeesturmCalendar, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionAddEventResponseDto
    func updateEvent(calendar: SeesturmCalendar, eventId: String, event: CloudFunctionEventPayloadDto) async throws -> CloudFunctionUpdateEventResponseDto
    func sendPushNotification(type: SeesturmFCMNotificationType) async throws -> CloudFunctionPushNotificationResponseDto
}
