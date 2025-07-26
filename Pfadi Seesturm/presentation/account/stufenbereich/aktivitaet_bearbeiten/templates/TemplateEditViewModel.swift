//
//  TemplateEditViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 20.07.2025.
//

import SwiftUI
import Observation

@Observable
@MainActor
class TemplateEditViewModel {
    
    var description: String
    
    private let mode: TemplateEditMode
    
    init(
        mode: TemplateEditMode
    ) {
        self.mode = mode
        switch mode {
        case .insert(_):
            self.description = ""
        case .update(let description, _):
            self.description = description
        }
    }
}
