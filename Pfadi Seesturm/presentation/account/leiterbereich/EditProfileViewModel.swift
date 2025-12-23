//
//  EditProfileViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

import SwiftUI
import Observation
import PhotosUI

@Observable
@MainActor
class EditProfileViewModel {
    
    // task to load image from storage into memory
    @ObservationIgnored private var imageFromGalleryLoadingTask: Task<Void, Never>? = nil
    
    // track current local image selection state
    var photosPickerItem: PhotosPickerItem? = nil {
        didSet {
            updateImageSelectionState()
        }
    }
    var imageSelectionState: UiState<ProfilePictureData> = .loading(subState: .idle)
    
    // track image uploading state
    var imageUploadState: ProgressActionState<Void> = .idle
    
    // track image deleting state
    var showDeleteImageConfirmationDialog: Bool = false
    var imageDeleteState: ActionState<Void> = .idle
    
    var imageSelectionStateBinding: Binding<ProfilePictureData?> {
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
                    withAnimation {
                        self.imageSelectionState = .loading(subState: .idle)
                    }
                }
            }
        )
    }
    
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
                let data = try await ProfilePictureData(from: item)
                withAnimation {
                    imageSelectionState = .success(data: data)
                }
            }
            catch {
                withAnimation {
                    imageSelectionState = .error(message: "Ein Fehler ist aufgetreten. Bitte wähle ein anderes Foto. \(error.localizedDescription)")
                }
            }
        }
    }
}
