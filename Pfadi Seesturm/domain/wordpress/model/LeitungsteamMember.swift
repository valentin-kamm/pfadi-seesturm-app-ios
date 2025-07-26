//
//  LeitungsteamMember.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//
import Foundation

struct LeitungsteamMember: Identifiable {
    let id: UUID
    let name: String
    let job: String
    let contact: String
    let photo: String
}

extension String {
    
    var toEmail: String? {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isEmail = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
        if isEmail {
            return self
        }
        else {
            return nil
        }
    }
}
