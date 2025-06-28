//
//  TemplateEditView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.05.2025.
//
import SwiftUI

struct TemplateEditView: View {
    
    @State private var description: String
    private let mode: TemplateEditMode
    private let editState: Binding<ActionState<Void>>
    
    init(
        mode: TemplateEditMode,
        editState: Binding<ActionState<Void>>
    ) {
        self.mode = mode
        self.editState = editState
        
        switch mode {
        case .insert:
            self.description = ""
        case .update(let description, _):
            self.description = description
        }
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            List {
                Section {
                    SeesturmHTMLEditor(
                        html: $description,
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
                                onSubmit(description)
                            case .update(_, let onSubmit):
                                onSubmit(description)
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
            .background(Color.customBackground)
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
    TemplateEditView(
        mode: .insert(onSubmit: { _ in }),
        editState: .constant(.loading(action: ()))
    )
}
#Preview("Idle") {
    TemplateEditView(
        mode: .update(
            description: "<b>Hallo</b>",
            onSubmit: { _ in }
        ),
        editState: .constant(.idle)
    )
}
