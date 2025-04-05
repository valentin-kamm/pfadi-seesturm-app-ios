//
//  TermineDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.11.2024.
//

import SwiftUI
import RichText

struct TermineDetailView: View {
    
    @StateObject var viewModel: TermineDetailViewModel
    let calendar: SeesturmCalendar
    
    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading(_):
                VStack(spacing: 16) {
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(2)
                        .font(.title)
                        .fontWeight(.bold)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(5)
                        .font(.body)
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            case .error(let message):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: message,
                    asyncRetryAction: {
                        await viewModel.fetchEvent()
                    }
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
                        CustomCardView(shadowColor: Color.clear, backgroundColor: Color(UIColor.systemGray5)) {
                            Text("Termin Leitungsteam")
                                .lineLimit(2)
                                .padding(8)
                                .font(.footnote)
                                .frame(maxHeight: .infinity)
                                .foregroundStyle(Color.SEESTURM_RED)
                        }
                    }
                    Label {
                        Text(event.fullDateTimeString)
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
                                    .customLoadingBlinking()
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .frame(maxHeight: .infinity)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIApplication.shared.open(calendar.data.subscriptionUrl)
                }) {
                    Image(systemName: "calendar.badge.plus")
                }
                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
            }
        }
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchEvent()
            }
        }
    }
}

#Preview("Mehrtägiger Anlass") {
    TermineDetailView(
        viewModel: TermineDetailViewModel(
            service: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().multiDayEventData()),
            calendar: .termine
        ),
        calendar: .termine
    )
}

#Preview("Eintägiger Anlass") {
    TermineDetailView(
        viewModel: TermineDetailViewModel(
            service: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().oneDayEventData()),
            calendar: .termine
        ),
        calendar: .termine
    )
}

#Preview("Ganztägiger, mehrtägiger Anlass") {
    TermineDetailView(
        viewModel: TermineDetailViewModel(
            service: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().allDayMultiDayEventData()),
            calendar: .termine
        ),
        calendar: .termine
    )
}

#Preview("Ganztägiger, eintägiger Anlass (Leitungsteam)") {
    TermineDetailView(
        viewModel: TermineDetailViewModel(
            service: AnlaesseService(
                repository: AnlaesseRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            ),
            input: .object(object: TermineCardViewPreviewExtension().allDayOneDayEventData()),
            calendar: .termine
        ),
        calendar: .termineLeitungsteam
    )
}
