//
//  Untitled.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 02.03.2025.
//
import Foundation

struct OAuthApplicationConfig {
    let issuer: URL
    let clientID: String
    let redirectUri: URL
    let scope: [String]
}
