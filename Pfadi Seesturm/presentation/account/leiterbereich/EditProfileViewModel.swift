//
//  EditProfileViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 11.08.2025.
//

import SwiftUI
import Observation
import PhotosUI

@Observable
@MainActor
class EditProfileViewModel {
    
    private let user: FirebaseHitobitoUser
    private let leiterbereichService: LeiterbereichService
    
    init(
        user: FirebaseHitobitoUser,
        leiterbereichService: LeiterbereichService
    ) {
        self.user = user
        self.leiterbereichService = leiterbereichService
    }
    
    // task to load image from gallery into memory
    @ObservationIgnored private var imageFromGalleryLoadingTask: Task<Void, Never>? = nil
    
    // track current local image selection state
    var photosPickerItem: PhotosPickerItem? = nil {
        didSet {
            updateImageSelectionState()
        }
    }
    var imageSelectionState: UiState<JPGData> = .loading(subState: .idle)
    
    // track image uploading process
    var imageUploadState: ProgressActionState<Void> = .idle
    
    // track image deleting process
    var showDeleteImageConfirmationDialog: Bool = false
    var imageDeleteState: ActionState<Void> = .idle
    
    // hide or show image cropper (full screen cover)
    var imageSelectionStateBinding: Binding<JPGData?> {
        Binding(
            get: {
                switch self.imageSelectionState {
                case .loading(_), .error(_):
                    return nil
                case .success(let data):
                    return data
                }
            },
            set: { newValue in
                if newValue == nil {
                    self.imageSelectionState = .loading(subState: .idle)
                }
            }
        )
    }
    
    // show snackbar when JPGData could not be retrieved from gallery
    var imageSelectionStateErrorSnackbarBinding: Binding<Bool> {
        Binding(
            get: {
                switch self.imageSelectionState {
                case .error(_):
                    return true
                default:
                    return false
                }
            },
            set: { isShown in
                if !isShown {
                    self.photosPickerItem = nil
                }
            }
        )
    }
    
    // determine whether the show loading spinner in circular image view
    var isCircularImageViewLoading: Bool {
        
        switch imageUploadState {
        case .loading(_, _):
            return true
        default:
            break
        }
        
        switch imageDeleteState {
        case .loading(_):
            return true
        default:
            break
        }
        
        switch imageSelectionState {
        case .loading(let subState):
            switch subState {
            case .loading:
                return true
            default:
                break
            }
        default:
            break
        }
        
        return false
    }
    
    private func updateImageSelectionState() {
        
        imageFromGalleryLoadingTask?.cancel()
        imageFromGalleryLoadingTask = nil
        
        guard let item = photosPickerItem else {
            imageSelectionState = .loading(subState: .idle)
            return
        }
        imageFromGalleryLoadingTask = Task {
            imageSelectionState = .loading(subState: .loading)
            do {
                let jpgData = try await JPGData(from: item)
                withAnimation {
                    imageSelectionState = .success(data: jpgData)
                }
            }
            catch {
                withAnimation {
                    imageSelectionState = .error(message: "Ein unbekannter Fehler ist aufgetreten. \(error.localizedDescription)")
                }
            }
        }
    }
    
    func uploadProfilePicture(data: JPGData) async {
        
        for await result in leiterbereichService.uploadProfilePicture(
            data: data,
            user: user
        ) {
            withAnimation {
                imageUploadState = result
            }
        }
    }
    
    func deleteProfilePicture() async {
        
        withAnimation {
            imageDeleteState = .loading(action: ())
        }
        
        let result = await leiterbereichService.deleteProfilePicture(user: user)
        
        switch result {
        case .error(let e):
            withAnimation {
                imageDeleteState = .error(action: (), message: e.defaultMessage)
            }
        case .success(_):
            withAnimation {
                imageDeleteState = .success(action: (), message: "Das Profilbild wurde erfolgreich gelöscht.")
            }
        }
    }
}
