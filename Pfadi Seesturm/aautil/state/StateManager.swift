//
//  PublishedUpdate.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.01.2025.
//
import SwiftUI

@MainActor
class StateManager<State>: ObservableObject {
    
    @Published private(set) var state: State
    
    init(initialState: State) {
        self.state = initialState
    }
    
    // update any property of published state
    func updateState(_ block: (inout State) -> Void) {
        var copy = state
        block(&copy)
        withAnimation {
            state = copy
        }
    }
    
    // create binding for any property of the published State
    func binding<Value>(for keyPath: WritableKeyPath<State, Value>) -> Binding<Value> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { newValue in
                self.updateState { state in
                    state[keyPath: keyPath] = newValue
                }
            }
        )
    }
}
