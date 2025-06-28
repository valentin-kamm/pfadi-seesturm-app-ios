//
//  FirebaseHitobitoUserRole.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//

enum FirebaseHitobitoUserRole: String, Hashable, Codable {
    
    case user = "hitobito_user"
    case admin = "hitobito_admin"
    
    init(claims: FirebaseUserClaims) throws {
        if let roleClaim = claims["role"] as? String, let role = FirebaseHitobitoUserRole(rawValue: roleClaim) {
            self = role
            return
        }
        throw PfadiSeesturmError.authError(message: "Du hast keine Berechtigung, um dich in der Pfadi Seesturm App anzumelden. Melde dich erneut via MiData an.")
    }
    
    init(role: String) throws {
        if let role = FirebaseHitobitoUserRole(rawValue: role) {
            self = role
            return
        }
        throw PfadiSeesturmError.authError(message: "Unbekannte Rolle. Melde dich erneut via MiData an.")
    }
}
