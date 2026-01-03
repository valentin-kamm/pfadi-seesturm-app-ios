//
//  TemplateEditView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.05.2025.
//
import SwiftUI

struct TemplateEditView: View {
    
    @State private var viewModel: TemplateEditViewModel
    private let mode: TemplateEditMode
    private let editState: Binding<ActionState<Void>>
    
    init(
        viewModel: TemplateEditViewModel,
        mode: TemplateEditMode,
        editState: Binding<ActionState<Void>>
    ) {
        self.viewModel = viewModel
        self.mode = mode
        self.editState = editState
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            List {
                Section {
                    SeesturmHTMLEditor(
                        html: $viewModel.description,
                        scrollable: true,
                        disabled: editState.wrappedValue.isLoading
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 150)
                } header: {
                    Text("Vorlage")
                }
                Section {
                    SeesturmButton(
                        type: .primary,
                        action: .sync(action: {
                            switch mode {
                            case .insert(let onSubmit):
                                onSubmit(viewModel.description)
                            case .update(_, let onSubmit):
                                onSubmit(viewModel.description)
                            }
                        }),
                        title: mode.buttonTitle,
                        isLoading: editState.wrappedValue.isLoading,
                        disabled: editState.wrappedValue.isLoading
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle(mode.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .actionSnackbar(
                action: editState,
                events: [
                    .error(dismissAutomatically: true, allowManualDismiss: true)
                ]
            )
        }
    }
}

#Preview("Loading") {
    let mode = TemplateEditMode.insert(onSubmit: { _ in })
    TemplateEditView(
        viewModel: TemplateEditViewModel(mode: mode),
        mode: mode,
        editState: .constant(.loading(action: ()))
    )
}
#Preview("Idle") {
    let mode = TemplateEditMode.update(
        description: "<b>Hallo</b>",
        onSubmit: { _ in }
    )
    TemplateEditView(
        viewModel: TemplateEditViewModel(mode: mode),
        mode: mode,
        editState: .constant(.idle)
    )
}
