//
//  BlinkViewModifier.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

struct BlinkViewModifier: ViewModifier {
    
    private let duration: Double
    @State private var blinking: Bool
    
    init(
        duration: Double,
        blinking: Bool = false
    ) {
        self.duration = duration
        self.blinking = blinking
    }

    func body(content: Content) -> some View {
        content
            .opacity(blinking ? 0.4 : 1)
            .animation(.easeInOut(duration: duration).repeatForever(), value: blinking)
            .onAppear {
                blinking.toggle()
            }
    }
}

extension View {
    func loadingBlinking(duration: Double = 0.75) -> some View {
        modifier(BlinkViewModifier(duration: duration + Double.random(in: -0.2...0.2)))
    }
}
