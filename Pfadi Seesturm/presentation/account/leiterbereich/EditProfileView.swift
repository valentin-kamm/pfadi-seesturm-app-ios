//
//  EditProfileView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.12.2025.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authState: AuthViewModel
    @State private var shouldShowFullscreenProfilePicture: Bool = false
    
    @State private var viewModel: EditProfileViewModel
    private let user: FirebaseHitobitoUser
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    
    init(
        viewModel: EditProfileViewModel,
        user: FirebaseHitobitoUser,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.user = user
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
    }
    
    private var fullscreenProfilePicture: Binding<PhotoSliderViewItem?> {
        Binding(
            get: {
                if shouldShowFullscreenProfilePicture && user.profilePictureUrl != nil {
                    PhotoSliderViewItem(from: user)
                }
                else {
                    nil
                }
            },
            set: { picture in
                shouldShowFullscreenProfilePicture = picture != nil
            }
        )
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            EditProfileContentView(
                user: user,
                profilePictureType: viewModel.isCircularImageViewLoading ? .loading : .idle(user: user),
                photosPickerItem: $viewModel.photosPickerItem,
                imageUploadState: viewModel.imageUploadState,
                onSignOut: {
                    dismiss()
                    onSignOut()
                },
                onDeleteAccount: {
                    dismiss()
                    onDeleteAccount()
                },
                onDeleteProfilePicture: {
                    deleteProfilePicture()
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
                        image: data.uiImage,
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
            .ignoresSafeArea()
        }
        .fullScreenCover(item: fullscreenProfilePicture) { item in
            PhotoSliderView(mode: .single(image: item))
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
    
    private func uploadProfilePicture(picture: ProfilePicture) {
                
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
    
    @State private var showDeleteImageConfirmationDialog: Bool = false
    @State private var showSignOutConfirmationDialog: Bool = false
    @State private var showDeleteAccountConfirmationDialog: Bool = false
    
    private let user: FirebaseHitobitoUser
    private let profilePictureType: CircleProfilePictureViewType
    private let photosPickerItem: Binding<PhotosPickerItem?>
    private let imageUploadState: ProgressActionState<Void>
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    private let onDeleteProfilePicture: () -> Void
    private let onOpenFullscreenProfilePicture: () -> Void
    
    init(
        user: FirebaseHitobitoUser,
        profilePictureType: CircleProfilePictureViewType,
        photosPickerItem: Binding<PhotosPickerItem?>,
        imageUploadState: ProgressActionState<Void>,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void,
        onDeleteProfilePicture: @escaping () -> Void,
        onOpenFullscreenProfilePicture: @escaping () -> Void
    ) {
        self.user = user
        self.profilePictureType = profilePictureType
        self.photosPickerItem = photosPickerItem
        self.imageUploadState = imageUploadState
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onDeleteProfilePicture = onDeleteProfilePicture
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
                        showDeleteImageConfirmationDialog = true
                    }
                    .disabled(user.profilePictureUrl == nil)
                    .foregroundStyle(Color.SEESTURM_RED)
                    .confirmationDialog("Möchtest du dein Profilbild wirklich löschen?", isPresented: $showDeleteImageConfirmationDialog, titleVisibility: .visible) {
                        Button("Abbrechen", role: .cancel) {}
                        Button("Löschen", role: .destructive) {
                            onDeleteProfilePicture()
                        }
                    }
                }
                Section {
                    Button("Abmelden", systemImage: "rectangle.portrait.and.arrow.right") {
                        showSignOutConfirmationDialog = true
                    }
                    .confirmationDialog(
                        "Möchtest du dich wirklich abmelden?",
                        isPresented: $showSignOutConfirmationDialog,
                        titleVisibility: .visible,
                        actions: {
                            Button("Abbrechen", role: .cancel) {
                                // do nothing
                            }
                            Button("Abmelden", role: .destructive) {
                                onSignOut()
                            }
                        }
                    )
                    .foregroundStyle(Color.SEESTURM_GREEN)
                    Button("App-Account löschen", systemImage: "person.badge.minus", role: .destructive) {
                        showDeleteAccountConfirmationDialog = true
                    }
                    .foregroundStyle(Color.SEESTURM_RED)
                    .confirmationDialog(
                        "Möchtest du deinen Account wirklich löschen?",
                        isPresented: $showDeleteAccountConfirmationDialog,
                        titleVisibility: .visible,
                        actions: {
                            Button("Abbrechen", role: .cancel) {
                                // do nothing
                            }
                            Button("Löschen", role: .destructive) {
                                onDeleteAccount()
                            }
                        }
                    )
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
            onSignOut: {},
            onDeleteAccount: {},
            onDeleteProfilePicture: {},
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
            onSignOut: {},
            onDeleteAccount: {},
            onDeleteProfilePicture: {},
            onOpenFullscreenProfilePicture: {}
        )
        .background(Color.customBackground)
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}
