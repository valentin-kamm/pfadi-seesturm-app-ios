//
//  SeesturmAppAttestProviderFactory.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2024.
//

import Foundation
import Firebase
import FirebaseAppCheck

class SeesturmAppAttestProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        return AppAttestProvider(app: app)
    }
}

class SeesturmAppAttestDebugProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        return AppCheckDebugProvider(app: app)//2147B59C-280E-4600-8913-D77D1F71CA7C
    }
}
