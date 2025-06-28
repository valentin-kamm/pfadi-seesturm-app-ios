//
//  FocusControlView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.06.2025.
//
import SwiftUI

struct FocusControlView<F: FocusControlItem, Content: View>: View {
    
    @FocusState private var focusedField: F?
    private let allFields: [F]
    @ViewBuilder private let content: (FocusState<F?>.Binding) -> Content
    
    init(
        allFields: [F],
        content: @escaping (FocusState<F?>.Binding) -> Content
    ) {
        self.allFields = allFields
        self.content = content
    }
    
    var body: some View {
        self.content($focusedField)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Fertig") {
                        focusedField = nil
                    }
                    Spacer()
                }
            }
            .onTapGesture {
                focusedField = nil
            }
    }
}
