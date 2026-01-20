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
    
    @State private var viewModel: AktivitaetDetailViewModel
    private let stufe: SeesturmStufe
    private let type: AktivitaetDetailViewType
    
    init(
        stufe: SeesturmStufe,
        type: AktivitaetDetailViewType,
        userId: String?,
        service: NaechsteAktivitaetService
    ) {
        self.stufe = stufe
        self.type = type
        
        switch self.type {
        case .home(let input):
            self.viewModel = AktivitaetDetailViewModel(
                input: input,
                service: service,
                stufe: stufe,
                userId: userId
            )
        case .stufenbereich(let event):
            self.viewModel = AktivitaetDetailViewModel(
                input: .object(object: event),
                service: service,
                stufe: stufe,
                userId: userId
            )
        }
    }
    
    var body: some View {
        AktivitaetDetailContentView(
            stufe: stufe,
            type: type,
            loadingState: viewModel.loadingState,
            onRetry: viewModel.getAktivitaet,
            onOpenSheet: { interaction in
                viewModel.selectedSheetMode = interaction
                viewModel.showSheet = true
            }
        )
        .task {
            if viewModel.loadingState.taskShouldRun {
                await viewModel.getAktivitaet()
            }
        }
        .sheet(isPresented: $viewModel.showSheet) {
            if case .success(let nullableAktivitaet) = viewModel.loadingState {
                if let aktivitaet = nullableAktivitaet {
                    AktivitaetAnAbmeldenView(
                        viewModel: $viewModel,
                        aktivitaet: aktivitaet,
                        stufe: stufe
                    )
                }
            }
        }
        .actionSnackbar(
            action: $viewModel.anAbmeldenState,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
    }
}

private struct AktivitaetDetailContentView: View {
    
    private let stufe: SeesturmStufe
    private let type: AktivitaetDetailViewType
    private let loadingState: UiState<GoogleCalendarEvent?>
    private let onRetry: () async -> Void
    private let onOpenSheet: (AktivitaetInteractionType) -> Void
    
    init(
        stufe: SeesturmStufe,
        type: AktivitaetDetailViewType,
        loadingState: UiState<GoogleCalendarEvent?>,
        onRetry: @escaping () async -> Void,
        onOpenSheet: @escaping (AktivitaetInteractionType) -> Void
    ) {
        self.stufe = stufe
        self.type = type
        self.loadingState = loadingState
        self.onRetry = onRetry
        self.onOpenSheet = onOpenSheet
    }
    
    var body: some View {
        ScrollView {
            switch loadingState {
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
                                .loadingBlinking()
                            Circle()
                                .fill(Color.skeletonPlaceholderColor)
                                .frame(width: 40, height: 40)
                                .loadingBlinking()
                        }
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(6)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .redacted(reason: .placeholder)
                            .loadingBlinking()
                    }
                    .padding()
                }
                .padding()
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.vertical)
            case .success(let aktivitaet):
                AktivitaetDetailCardView(
                    stufe: stufe,
                    aktivitaet: aktivitaet,
                    openSheet: onOpenSheet,
                    buttonsDisabled: type.anAbmeldenButtonsDisabled
                )
            }
        }
        .background(Color.customBackground)
        .navigationTitle(stufe.aktivitaetDescription)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CalendarSubscriptionButton(calendar: stufe.calendar)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if case .home(_) = type {
                    NavigationLink(value: HomeNavigationDestination.pushNotifications) {
                        Image(systemName: "bell.badge")
                    }
                }
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetDetailContentView(
            stufe: .wolf,
            type: .home(input: .id(id: "")),
            loadingState: .loading(subState: .loading),
            onRetry: { },
            onOpenSheet: { _ in }
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetDetailContentView(
            stufe: .biber,
            type: .home(input: .id(id: "")),
            loadingState: .error(message: "Schwerer Fehler"),
            onRetry: { },
            onOpenSheet: { _ in }
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetDetailContentView(
            stufe: .pio,
            type: .home(input: .id(id: "")),
            loadingState: .success(data: DummyData.aktivitaet1),
            onRetry: { },
            onOpenSheet: { _ in }
        )
    }
}
