//
//  DokumenteView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct DokumenteView: View {
    
    @StateObject var viewModel: DokumenteViewModel
    
    var body: some View {
        List {
            switch viewModel.state {
            case .loading(_):
                ForEach(1..<10) { index in
                    DokumenteLuuchtturmLoadingCell()
                        .listRowSeparator(.automatic)
                        .listRowInsets(EdgeInsets())
                }
            case .error(let message):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: message,
                    asyncRetryAction: {
                        await viewModel.fetchDocuments()
                    }
                )
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            case .success(let documents):
                ForEach(Array(documents.enumerated()), id: \.element.id) { index, document in
                    if let documentUrl = URL(string: document.url) {
                        Link(destination: documentUrl) {
                            DokumenteLuuchtturmCell(document: document)
                        }
                        .foregroundStyle(Color.primary)
                        .listRowSeparator(.automatic)
                        .listRowInsets(EdgeInsets())
                    }
                    else {
                        DokumenteLuuchtturmCell(document: document)
                            .listRowSeparator(.automatic)
                            .listRowInsets(EdgeInsets())
                            .opacity(0.5)
                    }
                }
            }
        }
            .background(Color.customBackground)
            .myListStyle(isListPlain: viewModel.state.isError)
            .scrollDisabled(viewModel.state.scrollingDisabled)
            .task {
                if viewModel.state.taskShouldRun {
                    await viewModel.fetchDocuments()
                }
            }
            .navigationTitle("Dokumente")
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DokumenteView(
        viewModel: DokumenteViewModel(
            service: WordpressDocumentsService(
                repository: WordpressDocumentRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        )
    )
}
