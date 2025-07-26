//
//  TemplateListView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.04.2025.
//
import SwiftUI
import RichText

struct TemplateListView: View {
    
    private let state: UiState<[AktivitaetTemplate]>
    private let stufe: SeesturmStufe
    private let mode: TemplateListViewMode
    private let onClick: (AktivitaetTemplate) -> Void
    
    init(
        state: UiState<[AktivitaetTemplate]>,
        stufe: SeesturmStufe,
        mode: TemplateListViewMode,
        onElementClick: @escaping (AktivitaetTemplate) -> Void
    ) {
        self.state = state
        self.stufe = stufe
        self.mode = mode
        self.onClick = onElementClick
    }
    
    private var isInEditMode: Bool {
        switch mode {
        case .use:
            return false
        case .edit(_, _, _, _):
            return true
        }
    }
    
    private var scrollDisabled: Bool {
        if case .success(let data) = state {
            return data.isEmpty || state.scrollingDisabled
        }
        return false
    }
    
    var body: some View {
        List {
            switch state {
            case .loading(_):
                ForEach(1..<5) { index in
                    Text(Constants.PLACEHOLDER_TEXT)
                        .lineLimit(5)
                        .redacted(reason: .placeholder)
                        .loadingBlinking()
                }
            case .error(let message):
                ErrorCardView(
                    errorDescription: message
                )
                .padding(.top)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            case .success(let data):
                if case .edit(_, let onDelete, let editState, let deleteState) = mode, !editState.isLoading, !deleteState.isLoading {
                    
                    let sortedTemplates = data.sorted { $0.created > $1.created }
                    
                    ForEach(sortedTemplates) { template in
                        ZStack {
                            RichText(html: template.description)
                                .transition(.none)
                                .linkOpenType(.none)
                                .placeholder(content: {
                                    Text(Constants.PLACEHOLDER_TEXT)
                                        .redacted(reason: .placeholder)
                                        .loadingBlinking()
                                })
                            Rectangle()
                                .fill(Color.customBackground.opacity(0.001))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    onClick(template)
                                }
                        }
                    }
                    .onDelete { indexSet in
                        deleteItems(indexSet, sortedTemplates, onDelete)
                    }
                }
                else {
                    ForEach(data.sorted { $0.created > $1.created }) { template in
                        ZStack {
                            RichText(html: template.description)
                                .transition(.none)
                                .linkOpenType(.none)
                                .placeholder(content: {
                                    Text(Constants.PLACEHOLDER_TEXT)
                                        .redacted(reason: .placeholder)
                                        .loadingBlinking()
                                })
                            Rectangle()
                                .fill(Color.customBackground.opacity(0.001))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture {
                                    onClick(template)
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("Vorlagen \(stufe.name)")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.customBackground)
        .dynamicListStyle(isListPlain: state.isError)
        .scrollDisabled(scrollDisabled)
        .toolbar {
            if case .edit(_, _, _, _) = mode, case .success(let data) = state, !data.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if case .edit(let onAddClick, _, _, _) = mode {
                    Button {
                        onAddClick()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Color.SEESTURM_GREEN)
                    }
                }
            }
        }
        .overlay {
            if case .success(let data) = state, data.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("Keine Vorlagen", systemImage: "text.page.slash")
                    },
                    description: {
                        if case .edit(_, _, _, _) = mode {
                            Text("Füge jetzt eine Vorlage hinzu, damit das Erstellen von Aktivitäten schneller geht.")
                        }
                    },
                    actions: {
                        if case .edit(let onAddClick, _, _, _) = mode {
                            SeesturmButton(
                                type: .primary,
                                action: .sync(action: onAddClick),
                                title: "Vorlage hinzufügen"
                            )
                        }
                    }
                )
                .background(Material.thick)
            }
        }
    }
    
    private func deleteItems(_ offsets: IndexSet, _ templates: [AktivitaetTemplate], _ onDelete: ([AktivitaetTemplate]) -> Void) {
        onDelete(
            offsets.map { templates[$0] }
        )
    }
}

#Preview("Loading") {
    NavigationStack(path: .constant(NavigationPath())) {
        TemplateListView(
            state: .loading(subState: .loading),
            stufe: .pio,
            mode: .use,
            onElementClick: { _ in }
        )
    }
}
#Preview("Error") {
    NavigationStack(path: .constant(NavigationPath())) {
        TemplateListView(
            state: .error(message: "Schwerer Fehler"),
            stufe: .pio,
            mode: .use,
            onElementClick: { _ in }
        )
    }
}
#Preview("Empty") {
    NavigationStack(path: .constant(NavigationPath())) {
        TemplateListView(
            state: .success(data: []),
            stufe: .pio,
            mode: .edit(
                onAddClick: {},
                onDelete: { _ in },
                editState: .idle,
                deleteState: .idle
            ),
            onElementClick: { _ in }
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        TemplateListView(
            state: .success(data: [DummyData.aktivitaetTemplate1, DummyData.aktivitaetTemplate2]),
            stufe: .pio,
            mode: .edit(
                onAddClick: {},
                onDelete: { _ in },
                editState: .idle,
                deleteState: .idle
            ),
            onElementClick: { _ in }
        )
    }
}
