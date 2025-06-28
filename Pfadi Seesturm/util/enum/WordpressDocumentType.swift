//
//  WordpressDocumentType.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//

enum WordpressDocumentType {
    
    case luuchtturm
    case documents
    
    var title: String {
        switch self {
        case .luuchtturm:
            return "Lüüchtturm"
        case .documents:
            return "Dokumente"
        }
    }
}
