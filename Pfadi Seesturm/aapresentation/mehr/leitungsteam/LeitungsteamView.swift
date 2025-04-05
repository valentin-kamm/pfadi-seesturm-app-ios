//
//  LeitungsteamView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 18.10.2024.
//

import SwiftUI

struct LeitungsteamView: View {
    
    @StateObject var viewModel: LeitungsteamViewModel
    let passedStufe: String
    @State var selectedStufe: String = ""
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        
        List {
            switch viewModel.state {
            case .loading(_):
                Section(header: Text("Abteilungsleitung")
                    .frame(height: 45, alignment: .leading)
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .redacted(reason: .placeholder)
                            .customLoadingBlinking()
                ) {
                    ForEach(1..<10) { index in
                        LeitungsteamLoadingCell()
                            .padding(.bottom)
                            .padding(.top, index == 1 ? 16 : 0)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                }
            case .error(let message):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: message,
                    asyncRetryAction: {
                        await viewModel.fetchLeitungsteam(isPullToRefresh: false)
                    }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .success(let leitungsteam):
                Section(header: HStack(alignment: .center, spacing: 16) {
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
                            title: "Stufen"
                        )
                    }
                }
                .frame(height: 45, alignment: .leading)
                .padding(.vertical, 8)
                ) {
                    if leitungsteam.map({ $0.teamName }).contains(selectedStufe) {
                        let members = leitungsteam.filter { $0.teamName == selectedStufe}.first?.members ?? []
                        ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                            LeitungsteamCell(member: member)
                                .padding(.bottom)
                                .padding(.top, index == 0 ? 16 : 0)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                    
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.customBackground)
        .scrollDisabled(viewModel.state.scrollingDisabled)
        .refreshable {
            await viewModel.fetchLeitungsteam(isPullToRefresh: true)
        }
        .onAppear {
            withAnimation {
                selectedStufe = passedStufe
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if passedStufe != selectedStufe {
                    withAnimation {
                        selectedStufe = passedStufe
                    }
                }
            }
        }
        .task {
            if viewModel.state.taskShouldRun {
                await viewModel.fetchLeitungsteam(isPullToRefresh: false)
            }
        }
        .navigationTitle("Leitungsteam")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    LeitungsteamView(
        viewModel: LeitungsteamViewModel(
            service: LeitungsteamService(
                repository: LeitungsteamRepositoryImpl(
                    api: WordpressApiImpl(
                        baseUrl: Constants.SEESTURM_API_BASE_URL
                    )
                )
            )
        ),
        passedStufe: "Abteilungsleitung"
    )
}
