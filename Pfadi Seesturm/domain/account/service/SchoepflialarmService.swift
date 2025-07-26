//
//  SchoepflialarmService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.04.2025.
//
import Foundation
import FirebaseFirestore

class SchoepflialarmService {
    
    private let firestoreRepository: FirestoreRepository
    private let fcmService: FCMService
    private let fcfRepository: CloudFunctionsRepository
    
    init(
        firestoreRepository: FirestoreRepository,
        fcmService: FCMService,
        fcfRepository: CloudFunctionsRepository
    ) {
        self.firestoreRepository = firestoreRepository
        self.fcmService = fcmService
        self.fcfRepository = fcfRepository
    }
    
    func observeSchoepflialarm() -> AsyncStream<SeesturmResult<SchoepflialarmDto, RemoteDatabaseError>> {
        return firestoreRepository.observeDocument(type: SchoepflialarmDto.self, document: .schopflialarm)
    }
    
    func observeSchoepflialarmReactions() -> AsyncStream<SeesturmResult<[SchoepflialarmReactionDto], RemoteDatabaseError>> {
        return firestoreRepository.observeCollection(type: SchoepflialarmReactionDto.self, collection: .schopflialarmReactions, filter: nil)
    }
    
    func sendSchöpflialarm(
        messageType: SchoepflialarmMessageType,
        user: FirebaseHitobitoUser
    ) async -> SeesturmResult<Void, SchoepflialarmError> {
        
        let pushNotificationType: SeesturmFCMNotificationType
        switch messageType {
        case .generic:
            pushNotificationType = .schoepflialarmGeneric(userName: user.displayNameShort)
        case .custom(let message):
            pushNotificationType = .schoepflialarmCustom(userName: user.displayNameShort, body: message)
        }
        
        do {
            
            try await fcmService.requestOrCheckNotificationPermission()
            try await checkLastSchoepflialarmTime()
            try await checkUserLocation()
            
            // first send push notification and only if this has finished, execute the other requests in parallel (usability reasons)
            let _ = try await fcfRepository.sendPushNotification(type: pushNotificationType)
                        
            async let updateSchoepflialarmResult: Void = try await firestoreRepository.performTransaction(
                type: SchoepflialarmDto.self,
                document: .schopflialarm,
                forceNewCreatedDate: true,
                update: { _ in
                    SchoepflialarmDto(
                        id: nil,
                        created: Timestamp(),
                        modified: Timestamp(),
                        message: pushNotificationType.content.body,
                        userId: user.userId
                    )
                }
            )
            async let deleteReactionsResult: Void = try await firestoreRepository.deleteAllDocuments(in: .schopflialarmReactions)
            
            let (_, _) = try await (updateSchoepflialarmResult, deleteReactionsResult)
            
            return .success(())
        }
        catch let schoepflialarmError as SchoepflialarmLocalizedError {
            return .error(schoepflialarmError.toSchoepflialarmError())
        }
        catch let error as PfadiSeesturmError {
            switch error {
            case .messagingPermissionError(_):
                return .error(.messagingPermissionMissing)
            default:
                return .error(.unknown(message: "Beim Senden des Schöpflialarm ist ein unbekannter Fehler aufgetreten. \(error.localizedDescription)"))
            }
        }
        catch {
            return .error(.unknown(message: "Beim Senden des Schöpflialarm ist ein unbekannter Fehler aufgetreten. \(error.localizedDescription)"))
        }
    }
    
    func sendSchoepflialarmReaction(
        user: FirebaseHitobitoUser,
        reaction: SchoepflialarmReactionType
    ) async -> SeesturmResult<Void, RemoteDatabaseError> {
        
        do {
        
            // check that user does not have a reaction yet
            let currentReactions: [SchoepflialarmReactionDto] = try await firestoreRepository.readCollection(collection: .schopflialarmReactions)
            guard !currentReactions.map({$0.userId}).contains(user.userId) else {
                return .error(.savingError)
            }
            
            let payload = SchoepflialarmReactionDto(
                created: Timestamp(),
                modified: Timestamp(),
                userId: user.userId,
                reaction: reaction.rawValue
            )
        
            let _ = try await fcfRepository.sendPushNotification(type: .schoepflialarmReactionGeneric(userName: user.displayNameShort, type: reaction))
            try await firestoreRepository.insertDocument(object: payload, collection: .schopflialarmReactions)
            return .success(())
        }
        catch {
            return .error(.savingError)
        }
    }
    
    @MainActor // MainActor required for the location service to work properly
    private func checkUserLocation() async throws {
        try await SchoepflialarmLocationService().checkUserLocation()
    }
    
    private func checkLastSchoepflialarmTime() async throws {
        
        let lastSchoepflialarm: SchoepflialarmDto = try await firestoreRepository.readDocument(document: .schopflialarm)
        let lastCreatedDate = try DateTimeUtil.shared.convertFirestoreTimestamp(timestamp: lastSchoepflialarm.created)
        let timeDiff = abs(Date().timeIntervalSince(lastCreatedDate))
        
        if !Constants.IS_DEBUG && timeDiff < Constants.SCHOPFLIALARM_MIN_PAUSE {
            throw SchoepflialarmLocalizedError.tooEarly(message: "Schöpflialarm wurde bereits ausgelöst. Es ist nur ein Schöpflialarm pro Stunde erlaubt.")
        }
    }
    
    func goToAppSettings() {
        fcmService.goToAppSettings()
    }
}

enum SchoepflialarmMessageType {
    case generic
    case custom(message: String)
}
