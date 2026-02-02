//
//  MultiStufenCapableEventController.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.01.2026.
//

@MainActor
protocol MultiStufenCapableEventController: AnyObject {
    
    var selectedStufen: Set<SeesturmStufe> { get set }
}
