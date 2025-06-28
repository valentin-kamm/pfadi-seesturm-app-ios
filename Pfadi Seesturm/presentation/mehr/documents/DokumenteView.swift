//
//  DokumenteView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct DocumentsView: View {
    
    @State private var viewModel: DocumentsViewModel
    private let documentType: WordpressDocumentType
    
    init(
        viewModel: DocumentsViewModel,
        documentType: WordpressDocumentType
    ) {
        self.viewModel = viewModel
        self.documentType = documentType
    }
    
    var body: some View {
        DocumentsContentView(
            documentsState: viewModel.documentsState,
            onRetry: {
                await viewModel.fetchDocuments()
            },
            documentType: documentType
        )
        .task {
            if viewModel.documentsState.taskShouldRun {
                await viewModel.fetchDocuments()
            }
        }
    }
}

private struct DocumentsContentView: View {
    
    private let documentsState: UiState<[WordpressDocument]>
    private let onRetry: () async -> Void
    private let documentType: WordpressDocumentType
    
    init(
        documentsState: UiState<[WordpressDocument]>,
        onRetry: @escaping () async -> Void,
        documentType: WordpressDocumentType
    ) {
        self.documentsState = documentsState
        self.onRetry = onRetry
        self.documentType = documentType
    }
    
    var body: some View {
        List {
            switch documentsState {
            case .loading(_):
                ForEach(1..<5) { index in
                    DocumentLoadingCardView()
                        .listRowSeparator(.automatic)
                        .listRowInsets(EdgeInsets())
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.vertical)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            case .success(let documents):
                if documents.isEmpty {
                    Text("Keine Dokumente")
                        .padding(.horizontal)
                        .padding(.vertical, 75)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondary)
                }
                else {
                    ForEach(Array(documents.enumerated()), id: \.element.id) { index, document in
                        if let documentUrl = URL(string: document.documentUrl) {
                            Link(destination: documentUrl) {
                                DocumentCardView(document: document)
                            }
                            .foregroundStyle(Color.primary)
                            .listRowSeparator(.automatic)
                            .listRowInsets(EdgeInsets())
                        }
                        else {
                            DocumentCardView(document: document)
                                .listRowSeparator(.automatic)
                                .listRowInsets(EdgeInsets())
                                .opacity(0.5)
                        }
                    }
                }
            }
        }
        .background(Color.customBackground)
        .navigationTitle(documentType.title)
        .dynamicListStyle(isListPlain: documentsState.isError)
        .scrollDisabled(documentsState.scrollingDisabled)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Laden") {
    NavigationStack(path: .constant(NavigationPath())) {
        DocumentsContentView(
            documentsState: .loading(subState: .loading),
            onRetry: {},
            documentType: .luuchtturm
        )
    }
}
#Preview("Fehler") {
    NavigationStack(path: .constant(NavigationPath())) {
        DocumentsContentView(
            documentsState: .error(message: "Fehler"),
            onRetry: {},
            documentType: .documents
        )
    }
}
#Preview("No documents") {
    NavigationStack(path: .constant(NavigationPath())) {
        DocumentsContentView(
            documentsState: .success(data: []),
            onRetry: {},
            documentType: .documents
        )
    }
}
#Preview("Erfolg") {
    NavigationStack(path: .constant(NavigationPath())) {
        DocumentsContentView(
            documentsState: .success(data: DummyData.documents),
            onRetry: {},
            documentType: .documents
        )
    }
}
