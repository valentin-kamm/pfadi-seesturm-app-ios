//
//  ListSectionHeaderType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//

enum ListSectionHeaderType {
    
    case blank
    case button(buttonTitle: String?, icon: SeesturmButtonIconType, action: SeesturmButtonAction)
    case stufenButton(selectedStufen: [SeesturmStufe], onClick: (SeesturmStufe) -> Void)
}
