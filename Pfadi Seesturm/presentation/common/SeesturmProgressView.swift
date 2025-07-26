//
//  SeesturmProgressView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 19.07.2025.
//
import SwiftUI

struct SeesturmProgressView: View {
    
    private let size: CGFloat
    private let color: Color
    private let duration: TimeInterval
    
    init(
        size: CGFloat = 12,
        color: Color = .primary,
        duration: TimeInterval = 0.75
    ) {
        self.size = size
        self.color = color
        self.duration = duration
    }
    
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: 2,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(rotation))
            .frame(width: size, height: size)
            .task {
                withAnimation(
                    Animation
                        .linear(duration: duration)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

#Preview {
    SeesturmProgressView()
}
