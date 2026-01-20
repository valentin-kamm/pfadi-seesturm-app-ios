//
//  TemplateView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.04.2025.
//
import SwiftUI

struct TemplateEditListView: View {
    
    @State private var viewModel: TemplateViewModel
    private let stufe: SeesturmStufe
    
    init(
        viewModel: TemplateViewModel,
        stufe: SeesturmStufe
    ) {
        self.viewModel = viewModel
        self.stufe = stufe
    }
    
    var body: some View {
        TemplateListView(
            state: viewModel.templatesState,
            mode: .edit(
                onAddClick: {
                    withAnimation {
                        viewModel.showInsertSheet = true
                    }
                },
                onDelete: { templates in
                    Task {
                        await viewModel.deleteTemplates(templates)
                    }
                },
                editState: viewModel.editState,
                deleteState: viewModel.deleteState
            ),
            navigationTitle: "Vorlagen \(stufe.name)",
            onElementClick: { template in
                withAnimation {
                    viewModel.editSheetTemplate = template
                }
            }
        )
        .task {
            await viewModel.observeTemplates()
        }
        .sheet(isPresented: $viewModel.showInsertSheet) {
            let mode: TemplateEditMode = .insert(onSubmit: { description in
                Task {
                    await viewModel.insertTemplate(description: description)
                }
            })
            TemplateEditView(
                viewModel: TemplateEditViewModel(mode: mode),
                mode: mode,
                editState: $viewModel.editState
            )
        }
        .sheet(isPresented: viewModel.showEditSheet) {
            if let template = viewModel.editSheetTemplate {
                let mode: TemplateEditMode = .update(
                    description: template.description,
                    onSubmit: { newDescription in
                        Task {
                            await viewModel.updateTemplate(id: template.id, description: newDescription)
                        }
                    }
                )
                TemplateEditView(
                    viewModel: TemplateEditViewModel(mode: mode),
                    mode: mode,
                    editState: $viewModel.editState
                )
            }
        }
        .actionSnackbar(
            action: $viewModel.editState,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
        .actionSnackbar(
            action: $viewModel.deleteState,
            events: [
                .success(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                ),
                .error(
                    dismissAutomatically: true,
                    allowManualDismiss: true
                )
            ]
        )
    }
}
