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
        viewModel: AktivitaetDetailViewModel,
        stufe: SeesturmStufe,
        type: AktivitaetDetailViewType
    ) {
        self.viewModel = viewModel
        self.stufe = stufe
        self.type = type
    }
        
    var body: some View {
        AktivitaetDetailContentView(
            type: type,
            stufe: stufe,
            loadingState: viewModel.loadingState,
            onRetry: viewModel.getAktivitaet,
            onOpenSheet: { interaction in
                withAnimation {
                    viewModel.selectedSheetMode = interaction
                    viewModel.showSheet = true
                }
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
    
    private let type: AktivitaetDetailViewType
    private let stufe: SeesturmStufe
    private let loadingState: UiState<GoogleCalendarEvent?>
    private let onRetry: () async -> Void
    private let onOpenSheet: (AktivitaetInteractionType) -> Void
    
    init(
        type: AktivitaetDetailViewType,
        stufe: SeesturmStufe,
        loadingState: UiState<GoogleCalendarEvent?>,
        onRetry: @escaping () async -> Void,
        onOpenSheet: @escaping (AktivitaetInteractionType) -> Void
    ) {
        self.type = type
        self.stufe = stufe
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
                    type: type
                )
            }
        }
        .background(Color.customBackground)
        .navigationTitle(type == .preview ? "Vorschau \(stufe.aktivitaetDescription)" : stufe.aktivitaetDescription)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CalendarSubscriptionButton(calendar: stufe.calendar)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if type == .home {
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
            type: .home,
            stufe: .wolf,
            loadingState: .loading(subState: .loading),
            onRetry: {},
            onOpenSheet: { _ in }
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetDetailContentView(
            type: .home,
            stufe: .biber,
            loadingState: .error(message: "Schwerer Fehler"),
            onRetry: {},
            onOpenSheet: { _ in }
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        AktivitaetDetailContentView(
            type: .home,
            stufe: .pio,
            loadingState: .success(data: DummyData.aktivitaet1),
            onRetry: {},
            onOpenSheet: { _ in }
        )
    }
}
