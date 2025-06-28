//
//  SeesturmHTMLToolbarAction.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.03.2025.
//
import InfomaniakRichHTMLEditor
import UIKit
import SwiftUI

enum SeesturmHTMLToolbarAction: Int, CaseIterable {
    
    case dismissKeyboard
    case undo
    case redo
    case bold
    case italic
    case underline
    case strikethrough
    case link
    case orderedList
    case unorderedList
    case removeFormat
         
    static let actionGroups: [[Self]] = [
        [.dismissKeyboard],
        [.undo, .redo],
        [.bold, .italic, .underline, .strikethrough],
        [.link],
        [.orderedList, .unorderedList],
        [.removeFormat]
    ]
    
    @MainActor
    func isSelected(_ textAttributes: TextAttributes) -> Bool {
        switch self {
        case .dismissKeyboard, .undo, .redo, .removeFormat:
            return false
        case .bold:
            return textAttributes.hasBold
        case .italic:
            return textAttributes.hasItalic
        case .underline:
            return textAttributes.hasUnderline
        case .strikethrough:
            return textAttributes.hasStrikethrough
        case .link:
            return textAttributes.hasLink
        case .orderedList:
            return textAttributes.hasOrderedList
        case .unorderedList:
            return textAttributes.hasUnorderedList
        }
    }
    
    var icon: UIImage? {
        let systemName: String = switch self {
        case .dismissKeyboard:
            "keyboard.chevron.compact.down"
        case .undo:
            "arrow.uturn.backward"
        case .redo:
            "arrow.uturn.forward"
        case .bold:
            "bold"
        case .italic:
            "italic"
        case .underline:
            "underline"
        case .strikethrough:
            "strikethrough"
        case .link:
            "link"
        case .orderedList:
            "list.number"
        case .unorderedList:
            "list.bullet"
        case .removeFormat:
            "xmark.circle"
        }
        return UIImage(systemName: systemName)
    }
    
    var buttonTint: UIColor {
        UIColor(Color.SEESTURM_GREEN)
    }
}
