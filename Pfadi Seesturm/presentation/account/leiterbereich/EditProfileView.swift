//
//  EditProfileView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @EnvironmentObject private var authState: AuthViewModel
    @State private var viewModel: EditProfileViewModel
    private let leiterbereichViewModel: LeiterbereichViewModel
    private let user: FirebaseHitobitoUser
    
    @State private var shouldShowFullscreenProfilePicture: Bool = false
    private var showFullscreenProfilePicture: Binding<Bool> {
        Binding(
            get: {
                shouldShowFullscreenProfilePicture && user.profilePictureUrl != nil
            },
            set: { isShown in
                if !isShown {
                    shouldShowFullscreenProfilePicture = false
                }
            }
        )
    }
    
    init(
        viewModel: EditProfileViewModel,
        leiterbereichViewModel: LeiterbereichViewModel,
        user: FirebaseHitobitoUser
    ) {
        self.viewModel = viewModel
        self.leiterbereichViewModel = leiterbereichViewModel
        self.user = user
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            EditProfileContentView(
                user: user,
                profilePictureType: viewModel.isCircularImageViewLoading ? .loading : .idle(user: user),
                photosPickerItem: $viewModel.photosPickerItem,
                imageUploadState: viewModel.imageUploadState,
                onDeleteProfilePicture: {
                    viewModel.showDeleteImageConfirmationDialog = true
                },
                onSignOut: {
                    leiterbereichViewModel.showSignOutConfirmationDialog = true
                },
                onDeleteAccount: {
                    leiterbereichViewModel.showDeleteAccountConfirmationDialog = true
                },
                onOpenFullscreenProfilePicture: {
                    shouldShowFullscreenProfilePicture = true
                }
            )
            .background(Color.customBackground)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.customBackground)
        .tint(Color.SEESTURM_GREEN)
        .fullScreenCover(item: viewModel.imageSelectionStateBinding) { data in
            GeometryReader { geometry in
                if geometry.size != .zero {
                    ProfilePictureCropperView(
                        image: data,
                        viewSize: geometry.size,
                        onCrop: { croppedImage in
                            viewModel.photosPickerItem = nil
                            uploadProfilePicture(picture: croppedImage)
                        },
                        onCancel: {
                            viewModel.photosPickerItem = nil
                        }
                    )
                }
            }
        }
        .fullScreenCover(isPresented: showFullscreenProfilePicture) {
            NavigationStack(path: .constant(NavigationPath())) {
                if let item = PhotoSliderViewItem(from: user) {
                    PhotoSliderView(mode: .single(image: item))
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Schliessen") {
                                    withAnimation {
                                        shouldShowFullscreenProfilePicture = false
                                    }
                                }
                            }
                        }
                }
            }
            .ignoresSafeArea()
        }
        .confirmationDialog("Möchtest du dein Profilbild wirklich löschen?", isPresented: $viewModel.showDeleteImageConfirmationDialog, titleVisibility: .visible) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                deleteProfilePicture()
            }
        }
        .actionSnackbar(
            action: $viewModel.imageDeleteState,
            events: [
                .error(dismissAutomatically: true, allowManualDismiss: true),
                .success(dismissAutomatically: true, allowManualDismiss: true)
            ]
        )
        .actionSnackbar(
            action: $viewModel.imageUploadState,
            events: [
                .error(dismissAutomatically: true, allowManualDismiss: true),
                .success(dismissAutomatically: true, allowManualDismiss: true)
            ]
        )
        .customSnackbar(
            show: viewModel.imageSelectionStateErrorSnackbarBinding,
            type: .error,
            message: "Das Bild konnte nicht aus der Galerie geladen werden. Bitte versuche es erneut.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
    
    private func uploadProfilePicture(picture: ProfilePictureData) {
                
        Task {
            for await result in authState.uploadProfilePicture(picture: picture) {
                switch result {
                case .loading(let progress):
                    withAnimation {
                        viewModel.imageUploadState = .loading(action: (), progress: progress)
                    }
                case .error(let message):
                    withAnimation {
                        viewModel.imageUploadState = .error(action: (), message: message)
                    }
                case .success(_, let message):
                    withAnimation {
                        viewModel.imageUploadState = .success(action: (), message: message)
                    }
                }
            }
        }
    }
    
    private func deleteProfilePicture() {
        
        Task {
            
            withAnimation {
                viewModel.imageDeleteState = .loading(action: ())
            }
            
            let result = await authState.deleteProfilePicture()
            
            switch result {
            case .error(let e):
                withAnimation {
                    viewModel.imageDeleteState = .error(action: (), message: e.defaultMessage)
                }
            case .success(_):
                withAnimation {
                    viewModel.imageDeleteState = .success(action: (), message: "Das Profilbild wurde erfolgreich gelöscht.")
                }
            }
        }
    }
}

private struct EditProfileContentView: View {
    
    private let user: FirebaseHitobitoUser
    private let profilePictureType: CircleProfilePictureViewType
    private let photosPickerItem: Binding<PhotosPickerItem?>
    private let imageUploadState: ProgressActionState<Void>
    private let onDeleteProfilePicture: () -> Void
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    private let onOpenFullscreenProfilePicture: () -> Void
    
    init(
        user: FirebaseHitobitoUser,
        profilePictureType: CircleProfilePictureViewType,
        photosPickerItem: Binding<PhotosPickerItem?>,
        imageUploadState: ProgressActionState<Void>,
        onDeleteProfilePicture: @escaping () -> Void,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void,
        onOpenFullscreenProfilePicture: @escaping () -> Void
    ) {
        self.user = user
        self.profilePictureType = profilePictureType
        self.photosPickerItem = photosPickerItem
        self.imageUploadState = imageUploadState
        self.onDeleteProfilePicture = onDeleteProfilePicture
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onOpenFullscreenProfilePicture = onOpenFullscreenProfilePicture
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        CircleProfilePictureView(
                            type: profilePictureType,
                            size: 120
                        )
                        .onTapGesture {
                            if user.profilePictureUrl != nil {
                                onOpenFullscreenProfilePicture()
                            }
                        }
                        .padding(.bottom, 4)
                        Text(user.displayNameFull)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .fontWeight(.bold)
                            .font(.callout)
                        if let em = user.email {
                            Text(em)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .font(.caption)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                Section {
                    PhotosPicker(
                        selection: photosPickerItem,
                        matching: .images
                    ) {
                        Label("Profilbild wählen", systemImage: "photo.on.rectangle.angled")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
                    .disabled(imageUploadState.isLoading)
                    Button("Profilbild löschen", systemImage: "trash", role: .destructive) {
                        onDeleteProfilePicture()
                    }
                    .disabled(user.profilePictureUrl == nil)
                    .foregroundStyle(Color.SEESTURM_RED)
                }
                Section {
                    Button("Abmelden", systemImage: "rectangle.portrait.and.arrow.right") {
                        onSignOut()
                    }
                    .foregroundStyle(Color.SEESTURM_GREEN)
                    Button("App-Account löschen", systemImage: "person.badge.minus", role: .destructive) {
                        onDeleteAccount()
                    }
                    .foregroundStyle(Color.SEESTURM_RED)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            if case .loading(_, let progress) = imageUploadState {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(Color.SEESTURM_GREEN)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview("Idle") {
    NavigationStack(path: .constant(NavigationPath())) {
        EditProfileContentView(
            user: DummyData.user3,
            profilePictureType: .idle(user: DummyData.user3),
            photosPickerItem: .constant(nil),
            imageUploadState: .idle,
            onDeleteProfilePicture: {},
            onSignOut: {},
            onDeleteAccount: {},
            onOpenFullscreenProfilePicture: {}
        )
        .background(Color.customBackground)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        EditProfileContentView(
            user: DummyData.user3,
            profilePictureType: .loading,
            photosPickerItem: .constant(nil),
            imageUploadState: .loading(action: (), progress: 0.66),
            onDeleteProfilePicture: {},
            onSignOut: {},
            onDeleteAccount: {},
            onOpenFullscreenProfilePicture: {}
        )
        .background(Color.customBackground)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}
