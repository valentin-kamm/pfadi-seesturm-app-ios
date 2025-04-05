//
//  AktivitaetDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI
import RichText
import FirebaseFirestore

struct AktivitaetDetailView: View {
    
    @StateObject var viewModel: AktivitaetDetailViewModel
    let stufe: SeesturmStufe
    let isPreview: Bool
        
    var body: some View {
        ScrollView {
            switch viewModel.state.loadingState {
            case .loading(_):
                CustomCardView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 16) {
                            Text(Constants.PLACEHOLDER_TEXT)
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                            Circle()
                                .fill(Color.skeletonPlaceholderColor)
                                .frame(width: 40, height: 40)
                                .customLoadingBlinking()
                        }
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(6)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                    }
                    .padding()
                }
                .padding()
            case .error(let message):
                CardErrorView(
                    errorDescription: message,
                    asyncRetryAction: {
                        await viewModel.getAktivitaet()
                    }
                )
                .padding(.vertical)
            case .success(let aktivitaet):
                AktivitaetDetailCardView(
                    stufe: stufe,
                    aktivitaet: aktivitaet,
                    openSheet: { interaction in
                        viewModel.changeSheetMode(interaction: interaction)
                        viewModel.showSheet()
                    },
                    isPreview: isPreview
                )
            }
        }
        .background(Color.customBackground)
        .navigationTitle(stufe.aktivitaetDescription)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getAktivitaet()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    UIApplication.shared.open(stufe.calendar.data.subscriptionUrl)
                } label: {
                    Image(systemName: "calendar.badge.plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: HomeNavigationDestination.pushNotifications) {
                    Image(systemName: "bell.badge")
                }
            }
        }
        .sheet(isPresented: viewModel.showSheetBinding) {
            if case .success(let nullableAktivitaet) = viewModel.state.loadingState {
                if let aktivitaet = nullableAktivitaet {
                    AktivitaetAnAbmeldenView(
                        viewModel: viewModel,
                        aktivitaet: aktivitaet,
                        stufe: stufe
                    )
                }
            }
        }
        .actionSnackbar(
            action: viewModel.anAbmeldenStateBinding,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
    }
}

#Preview("Aktivität übergeben") {
    AktivitaetDetailView(
        viewModel: AktivitaetDetailViewModel(
            service: NaechsteAktivitaetService(
                repository: NaechsteAktivitaetRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: Firestore.firestore(),
                    api: FirestoreApiImpl(
                        db: Firestore.firestore()
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().oneDayEventData()),
            stufe: .biber,
            userId: nil
        ),
        stufe: .biber,
        isPreview: false
    )
}

#Preview("Aktivität noch nicht fertig geplant") {
    AktivitaetDetailView(
        viewModel: AktivitaetDetailViewModel(
            service: NaechsteAktivitaetService(
                repository: NaechsteAktivitaetRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: Firestore.firestore(),
                    api: FirestoreApiImpl(
                        db: Firestore.firestore()
                    )
                )
            ),
            input: .object(object: nil),
            stufe: .pio,
            userId: nil
        ),
        stufe: .pio,
        isPreview: false
    )
}

#Preview("ID übergeben") {
    AktivitaetDetailView(
        viewModel: AktivitaetDetailViewModel(
            service: NaechsteAktivitaetService(
                repository: NaechsteAktivitaetRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                ),
                firestoreRepository: FirestoreRepositoryImpl(
                    db: Firestore.firestore(),
                    api: FirestoreApiImpl(
                        db: Firestore.firestore()
                    )
                )
            ),
            input: .id(id: "2337fuo04n6lv5lju4kgflrqmq"),
            stufe: .pio,
            userId: nil
        ),
        stufe: .pio,
        isPreview: false
    )
}
