//
//  ProfilePictureService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//
import Foundation

class ProfilePictureService {
    
    private let storageRepository: StorageRepository
    private let firestoreRepository: FirestoreRepository
    
    init(
        storageRepository: StorageRepository,
        firestoreRepository: FirestoreRepository
    ) {
        self.storageRepository = storageRepository
        self.firestoreRepository = firestoreRepository
    }
    
    func uploadProfilePicture(user: FirebaseHitobitoUser, picture: ProfilePictureData, onProgress: @escaping (Double) -> Void) async -> SeesturmResult<URL, StorageError> {
        
        do {
            let downloadUrl = try await storageRepository.uploadData(
                item: .profilePicture(user: user, data: picture)
            ) { progress in
                onProgress(0.9 * progress)
            }
            try await firestoreRepository.performTransaction(
                type: FirebaseHitobitoUserDto.self,
                document: .user(id: user.userId),
                forceNewCreatedDate: false,
                update: { oldUser in
                    FirebaseHitobitoUserDto(from: oldUser, newProfilePictureUrl: downloadUrl.absoluteString)
                }
            )
            onProgress(1)
            return .success(downloadUrl)
        }
        catch {
            let message: String
            if let pfadiSeesturmError = error as? PfadiSeesturmError {
                message = pfadiSeesturmError.localizedDescription
            }
            else {
                message = "Beim Hochladen des Profilbilds ist ein unbekannter Fehler aufgetreten."
            }
            return .error(.uploadingError(message: message))
        }
    }
    
    func deleteProfilePicture(user: FirebaseHitobitoUser) async -> SeesturmResult<Void, StorageError> {
        
        do {
            try await storageRepository.deleteData(item: .profilePicture(user: user))
            try await firestoreRepository.performTransaction(
                type: FirebaseHitobitoUserDto.self,
                document: .user(id: user.userId),
                forceNewCreatedDate: false) { oldUser in
                    FirebaseHitobitoUserDto(from: oldUser, newProfilePictureUrl: nil)
                }
            return .success(())
        }
        catch {
            let message: String
            if let pfadiSeesturmError = error as? PfadiSeesturmError {
                message = pfadiSeesturmError.localizedDescription
            }
            else {
                message = "Beim Hochladen des Profilbilds ist ein unbekannter Fehler aufgetreten."
            }
            return .error(.deletingError(message: message))
        }
    }
}
