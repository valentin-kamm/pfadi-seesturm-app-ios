//
//  HtmlTrimmed.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 07.06.2025.
//
import Foundation

extension String {
    
    var htmlTrimmed: String {
        
        guard let data = self.data(using: .utf8) else {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
