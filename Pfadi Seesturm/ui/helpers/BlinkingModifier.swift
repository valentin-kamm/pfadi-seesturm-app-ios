//
//  ShimmerModifier.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

// simple view modifier that adds a blinking animation to any view to indicate a loading process
struct BlinkViewModifier: ViewModifier {
    
    let duration: Double
    @State private var blinking: Bool = false

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
    func customLoadingBlinking(duration: Double = 0.75) -> some View {
        modifier(BlinkViewModifier(duration: duration + Double.random(in: -0.2...0.2)))
    }
}
