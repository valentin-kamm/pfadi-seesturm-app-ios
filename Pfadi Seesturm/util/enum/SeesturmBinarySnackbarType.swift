//
//  SeesturmBinarySnackbarType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//

enum SeesturmBinarySnackbarType {
    
    case error(dismissAutomatically: Bool, allowManualDismiss: Bool)
    case success(dismissAutomatically: Bool, allowManualDismiss: Bool)
}
