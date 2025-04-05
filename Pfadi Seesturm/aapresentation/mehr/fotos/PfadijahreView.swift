//
//  PfadijahreView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct PfadijahreView: View {
    
    @ObservedObject var viewModel: PfadijahreViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        Group {
            GeometryReader { geometry in
                let width = (geometry.size.width - 3 * 16) / 2
                ScrollView {
                    switch viewModel.state {
                    case .loading(_):
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(1..<100) { _ in
                                PhotoGalleryLoadingCell(size: width, withText: true)
                            }
                        }
                        .padding(.horizontal)
                    case .error(let message):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: message,
                            asyncRetryAction: {
                                await viewModel.fetchPfadijahre(isPullToRefresh: false)
                            }
                        )
                        .padding(.vertical)
                    case .success(let pfadijahre):
                        if pfadijahre.count == 0 {
                            VStack {
                                Text("Keine Fotos")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .foregroundStyle(Color.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(pfadijahre.reversed(), id: \.id) { pfadijahr in
                                    NavigationLink(value: MehrNavigationDestination.albums(album: pfadijahr)) {
                                        PhotoGalleryCell(
                                            size: width,
                                            thumbnailUrl: pfadijahr.thumbnail,
                                            title: pfadijahr.title
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
                .scrollDisabled(viewModel.state.scrollingDisabled)
            }
        }
        .navigationTitle("Fotos")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchPfadijahre(isPullToRefresh: false)
            }
        }
    }
}

#Preview("Im Mehr Tab") {
    PfadijahreView(
        viewModel: PfadijahreViewModel(
            service: PhotosService(
                repository: PhotosRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        )
    )
}
