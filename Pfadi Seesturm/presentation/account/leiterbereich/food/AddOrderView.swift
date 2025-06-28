//
//  AddOrderView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.01.2025.
//

import SwiftUI

struct AddOrderView: View {
    
    private let newFoodItemDescription: Binding<String>
    private let newFoodItemCount: Binding<Int>
    private let addNewOrderState: Binding<ActionState<Void>>
    private let onSubmit: () -> Void
    
    init(
        newFoodItemDescription: Binding<String>,
        newFoodItemCount: Binding<Int>,
        addNewOrderState: Binding<ActionState<Void>>,
        onSubmit: @escaping () -> Void
    ) {
        self.newFoodItemDescription = newFoodItemDescription
        self.newFoodItemCount = newFoodItemCount
        self.addNewOrderState = addNewOrderState
        self.onSubmit = onSubmit
    }
    
    private enum AddOrderFields: String, FocusControlItem {
        case item
        var id: AddOrderFields { self }
    }
    
    var body: some View {
        NavigationStack(path: .constant(NavigationPath())) {
            FocusControlView(allFields: AddOrderFields.allCases) { focused in
                Form {
                    Section {
                        TextField("Bestellung", text: newFoodItemDescription)
                            .textFieldStyle(.roundedBorder)
                            .focused(focused, equals: .item)
                            .submitLabel(.done)
                            .onSubmit {
                                focused.wrappedValue = nil
                            }
                        Picker("Anzahl", selection: newFoodItemCount) {
                            ForEach(1..<11) { amount in
                                Text("\(amount)")
                                    .tag(amount)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .tint(Color.SEESTURM_GREEN)
                    }
                    Section {
                        SeesturmButton(
                            type: .primary,
                            action: .async(action: onSubmit),
                            title: "Speichern",
                            isLoading: addNewOrderState.wrappedValue.isLoading
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .actionSnackbar(
                action: addNewOrderState,
                events: [
                    .error(
                        dismissAutomatically: true,
                        allowManualDismiss: true
                    )
                ]
            )
            .navigationTitle("Neue Bestellung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Idle") {
    AddOrderView(
        newFoodItemDescription: .constant("Dürüm"),
        newFoodItemCount: .constant(3),
        addNewOrderState: .constant(.idle),
        onSubmit: {}
    )
}
#Preview("Loading") {
    AddOrderView(
        newFoodItemDescription: .constant("Dürüm"),
        newFoodItemCount: .constant(3),
        addNewOrderState: .constant(.loading(action: ())),
        onSubmit: {}
    )
}
