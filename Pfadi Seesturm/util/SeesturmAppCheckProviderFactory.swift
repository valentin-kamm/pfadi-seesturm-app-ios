//
//  SeesturmAppCheckProviderFactory.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2024.
//

import Firebase
import FirebaseAppCheck

class SeesturmAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    
    func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
        
        #if DEBUG
        return AppCheckDebugProvider(app: app)
        #else
        return AppAttestProvider(app: app)
        #endif
    }
}
