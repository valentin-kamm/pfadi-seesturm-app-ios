//
//  LeitungsteamView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

struct LeitungsteamView: View {
    
    @State private var viewModel: LeitungsteamViewModel
    
    init(
        viewModel: LeitungsteamViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        LeitungsteamContentView(
            leitungsteamState: viewModel.leitungsteamState,
            onRetry: {
                await viewModel.fetchLeitungsteam()
            }
        )
        .task {
            if viewModel.leitungsteamState.taskShouldRun {
                await viewModel.fetchLeitungsteam()
            }
        }
    }
}

private struct LeitungsteamContentView: View {
    
    @State private var selectedStufe: String = "Abteilungsleitung"
    
    private let leitungsteamState: UiState<[Leitungsteam]>
    private let onRetry: () async -> Void
    
    init(
        leitungsteamState: UiState<[Leitungsteam]>,
        onRetry: @escaping () async -> Void
    ) {
        self.leitungsteamState = leitungsteamState
        self.onRetry = onRetry
    }
    
    var body: some View {
        List {
            switch leitungsteamState {
            case .loading(_):
                Section {
                    ForEach(1..<10) { index in
                        LeitungsteamLoadingCell()
                            .padding(.vertical, 8)
                    }
                } header: {
                    Text("Abteilungsleitung")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.vertical, 16)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message,
                    action: .async(action: onRetry)
                )
                .padding(.top)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .success(let leitungsteam):
                Section {
                    if leitungsteam.map({ $0.teamName }).contains(selectedStufe) {
                        let members = leitungsteam.filter { $0.teamName == selectedStufe}.first?.members ?? []
                        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                            LeitungsteamCell(member: member)
                                .padding(.vertical, 8)
                        }
                    }
                } header: {
                    HStack(alignment: .center, spacing: 16) {
                        Text(selectedStufe)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .fontWeight(.bold)
                            .allowsTightening(true)
                        VStack {
                            DropdownButton(
                                items: leitungsteam.reversed().map {
                                    DropdownItemImpl(
                                        title: $0.teamName,
                                        item: $0.teamName,
                                        icon: .checkmark(isShown: selectedStufe == $0.teamName)
                                    )
                                },
                                onItemClick: { teamName in
                                    withAnimation {
                                        selectedStufe = teamName.item
                                    }
                                },
                                title: "Stufe"
                            )
                        }
                    }
                    .padding(.vertical, 16)
                    .textCase(nil)
                }
            }
        }
        .dynamicListStyle(isListPlain: leitungsteamState.isError)
        .background(Color.customBackground)
        .scrollDisabled(leitungsteamState.scrollingDisabled)
        .navigationTitle("Leitungsteam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeitungsteamContentView(
            leitungsteamState: .loading(subState: .loading),
            onRetry: {}
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeitungsteamContentView(
            leitungsteamState: .error(message: "Schwerer Fehler"),
            onRetry: {}
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        LeitungsteamContentView(
            leitungsteamState: .success(data: [
                Leitungsteam(
                    id: 123,
                    teamName: "Abteilungsleitung",
                    members: [
                        DummyData.leitungsteamMember,
                        DummyData.leitungsteamMember
                    ]
                )
            ]),
            onRetry: {}
        )
    }
}
