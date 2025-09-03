//
//  EditProfileView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 11.08.2025.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @State private var viewModel: EditProfileViewModel
    private let leiterbereichViewModel: LeiterbereichViewModel
    private let user: FirebaseHitobitoUser
    
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
        NavigationView {
            EditProfileContentView(
                user: user,
                profilePictureType: viewModel.isCircularImageViewLoading ? .loading : .user(user: user),
                imageUploadState: viewModel.imageUploadState,
                photosPickerItem: $viewModel.photosPickerItem,
                onSignOut: {
                    leiterbereichViewModel.showSignOutConfirmationDialog = true
                },
                onDeleteAccount: {
                    leiterbereichViewModel.showDeleteAccountConfirmationDialog = true
                },
                onDeleteProfilePicture: {
                    viewModel.showDeleteImageConfirmationDialog = true
                }
            )
            .background(Color.customBackground)
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.SEESTURM_GREEN)
            .fullScreenCover(item: viewModel.imageSelectionStateBinding) { data in
                GeometryReader { geometry in
                    if geometry.size != .zero {
                        CircularImageCropperView(
                            image: data,
                            viewSize: geometry.size,
                            onCrop: { croppedImage in
                                viewModel.photosPickerItem = nil
                                Task {
                                    await viewModel.uploadProfilePicture(data: croppedImage)
                                }
                            },
                            onCancel: {
                                viewModel.photosPickerItem = nil
                            }
                        )
                    }
                }
            }
            .confirmationDialog("Möchtest du dein Profilbild wirklich löschen?", isPresented: $viewModel.showDeleteImageConfirmationDialog, titleVisibility: .visible, actions: {
                Button("Abbrechen", role: .cancel) {
                    // do nothing
                }
                Button("Löschen", role: .destructive) {
                    Task {
                        await viewModel.deleteProfilePicture()
                    }
                }
            })
            .actionSnackbar(
                action: $viewModel.imageDeleteState,
                events: [
                    .error(dismissAutomatically: true, allowManualDismiss: true),
                    .success(dismissAutomatically: true, allowManualDismiss: true)
                ]
            )
            .progressActionSnackbar(
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
    }
}

struct EditProfileContentView: View {
    
    private let user: FirebaseHitobitoUser
    private let profilePictureType: ProfilePictureType
    private let imageUploadState: ProgressActionState<Void>
    private let photosPickerItem: Binding<PhotosPickerItem?>
    private let onSignOut: () -> Void
    private let onDeleteAccount: () -> Void
    private let onDeleteProfilePicture: () -> Void
    
    init(
        user: FirebaseHitobitoUser,
        profilePictureType: ProfilePictureType,
        imageUploadState: ProgressActionState<Void>,
        photosPickerItem: Binding<PhotosPickerItem?>,
        onSignOut: @escaping () -> Void,
        onDeleteAccount: @escaping () -> Void,
        onDeleteProfilePicture: @escaping () -> Void
    ) {
        self.user = user
        self.profilePictureType = profilePictureType
        self.imageUploadState = imageUploadState
        self.photosPickerItem = photosPickerItem
        self.onSignOut = onSignOut
        self.onDeleteAccount = onDeleteAccount
        self.onDeleteProfilePicture = onDeleteProfilePicture
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Form {
                Section {
                    VStack(alignment: .center, spacing: 8) {
                        CircleProfilePictureView(
                            type: profilePictureType,
                            size: 120,
                            showEditBadge: false
                        )
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
                    .disabled(!user.hasProfilePicture)
                }
                Section {
                    Button("Abmelden", systemImage: "rectangle.portrait.and.arrow.right") {
                        onSignOut()
                    }
                    Button("App-Account löschen", systemImage: "person.badge.minus", role: .destructive) {
                        onDeleteAccount()
                    }
                }
            }
            if case .loading(_, let progress) = imageUploadState {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .tint(Color.SEESTURM_GREEN)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditProfileContentView(
            user: DummyData.user3,
            profilePictureType: .user(user: DummyData.user1),
            imageUploadState: .loading(action: (), progress: 0.3434),
            photosPickerItem: .constant(nil),
            onSignOut: {},
            onDeleteAccount: {},
            onDeleteProfilePicture: {}
        )
    }
}
