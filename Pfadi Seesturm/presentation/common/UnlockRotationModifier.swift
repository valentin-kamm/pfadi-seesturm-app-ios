//
//  UnlockRotationModifier.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.07.2025.
//
import SwiftUI

private struct UnlockRotationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .allButUpsideDown))
                }
            }
            .onDisappear {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            }
    }
}

extension View {
    func unlockRotation() -> some View {
        self.modifier(UnlockRotationModifier())
    }
}
