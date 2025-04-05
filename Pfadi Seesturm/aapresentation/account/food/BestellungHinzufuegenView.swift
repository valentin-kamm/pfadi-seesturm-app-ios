//
//  EssenBestellenInsertSheet.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 01.01.2025.
//

import SwiftUI

struct BestellungHinzufuegenView: View {
    
    let newFoodItemDescription: Binding<String>
    let newFoodItemCount: Binding<Int>
    let isButtonLoading: Bool
    let addNewOrderStateBinding: Binding<ActionState<Void>>
    let onSubmit: () async -> Void
    
    @State private var dummyNavigationPath: NavigationPath = NavigationPath()
    
    private let possibleAmounts = Array(1...10)
    
    var body: some View {
        NavigationStack(path: $dummyNavigationPath) {
            Form {
                Section {
                    TextField("Bestellung", text: newFoodItemDescription)
                        .textFieldStyle(.roundedBorder)
                    Picker("Anzahl", selection: newFoodItemCount) {
                        ForEach(possibleAmounts, id: \.self) { amount in
                            Text("\(amount)")
                                .tag(amount)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(Color.SEESTURM_GREEN)
                }
                Section {
                    SeesturmButton(
                        style: .primary,
                        action: .async(action: onSubmit),
                        title: "Speichern",
                        isLoading: isButtonLoading
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .actionSnackbar(
                action: addNewOrderStateBinding,
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

#Preview {
    BestellungHinzufuegenView(
        newFoodItemDescription: .constant("Dürüm"),
        newFoodItemCount: .constant(1),
        isButtonLoading: true,
        addNewOrderStateBinding: .constant(.idle),
        onSubmit: {}
    )
}
