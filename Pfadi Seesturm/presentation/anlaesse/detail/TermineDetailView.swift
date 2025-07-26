//
//  TermineDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.11.2024.
//

import SwiftUI
import RichText

struct TermineDetailView: View {
    
    @State private var viewModel: TermineDetailViewModel
    private let calendar: SeesturmCalendar
    
    init(
        viewModel: TermineDetailViewModel,
        calendar: SeesturmCalendar
    ) {
        self.viewModel = viewModel
        self.calendar = calendar
    }
    
    var body: some View {
        TermineDetailContentView(
            terminState: viewModel.terminState,
            calendar: calendar,
            onRetry: {
                await viewModel.fetchEvent()
            }
        )
        .task {
            if viewModel.terminState.taskShouldRun {
                await viewModel.fetchEvent()
            }
        }
    }
}

private struct TermineDetailContentView: View {
    
    private let terminState: UiState<GoogleCalendarEvent>
    private let calendar: SeesturmCalendar
    private let onRetry: () async -> Void
    
    init(
        terminState: UiState<GoogleCalendarEvent>,
        calendar: SeesturmCalendar,
        onRetry: @escaping () async -> Void
    ) {
        self.terminState = terminState
        self.calendar = calendar
        self.onRetry = onRetry
    }
    
    var body: some View {
        ScrollView {
            switch terminState {
            case .loading(_):
                VStack(spacing: 16) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(2)
                        .font(.title)
                        .fontWeight(.bold)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(5)
                        .font(.body)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.vertical)
            case .success(let event):
                VStack(alignment: .leading, spacing: 16) {
                    Text(event.title)
                        .multilineTextAlignment(.leading)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if calendar.isLeitungsteam {
                        CustomCardView(shadowColor: Color.clear, backgroundColor: .seesturmGray) {
                            Text("Leitungsteam")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.SEESTURM_RED)
                        }
                    }
                    Label {
                        Text(event.fullDateTimeFormatted)
                            .foregroundStyle(Color.secondary)
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if let location = event.location {
                        Label {
                            Text(location)
                                .foregroundStyle(Color.secondary)
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "location")
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                        }
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if let description = event.description {
                        RichText(html: description)
                            .transition(.none)
                            .linkOpenType(.SFSafariView())
                            .placeholder(content: {
                                Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                                    .padding(.bottom, -100)
                                    .padding(.horizontal)
                                    .font(.body)
                                    .redacted(reason: .placeholder)
                                    .loadingBlinking()
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .background(Color.customBackground)
        .disabled(terminState.scrollingDisabled)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CalendarSubscriptionButton(calendar: calendar)
            }
        }
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .loading(subState: .loading),
            calendar: .termine,
            onRetry: {}
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .error(message: "Schwerer Fehler"),
            calendar: .termine,
            onRetry: {}
        )
    }
}
#Preview("Multi day event") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .success(data: DummyData.multiDayEvent),
            calendar: .termine,
            onRetry: {}
        )
    }
}
#Preview("One day event") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .success(data: DummyData.oneDayEvent),
            calendar: .termine,
            onRetry: {}
        )
    }
}
#Preview("All-day, multi day event") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .success(data: DummyData.allDayMultiDayEvent),
            calendar: .termineLeitungsteam,
            onRetry: {}
        )
    }
}
#Preview("All-day, one day event") {
    NavigationStack(path: .constant(NavigationPath())) {
        TermineDetailContentView(
            terminState: .success(data: DummyData.allDayOneDayEvent),
            calendar: .termineLeitungsteam,
            onRetry: {}
        )
    }
}
