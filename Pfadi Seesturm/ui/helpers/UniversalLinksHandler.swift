//
//  UniversalLinksHandler.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.12.2024.
//

import SwiftUI

class UniversalLinksHandler {
    
    static let shared = UniversalLinksHandler()
    
    func getNavigationDestinationFromUniversalLink(url: URL) -> (AppMainTab, NavigationPath)? {
        
        if url.host(percentEncoded: true) != "seesturm.ch" {
            return nil
        }
        
        let pathComponents = url.pathComponents
        let pathComponentsCount = pathComponents.count
        
        // aktuell
        if pathComponentsCount == 2 && pathComponents.last == "aktuell" {
            return (AppMainTab.aktuell, NavigationPath())
        }
        
        // aktuell post
        if pathComponentsCount == 3,
           url.pathComponents[1] == "aktuell",
           let postId = Int(url.lastPathComponent) {
            return (AppMainTab.aktuell, NavigationPath([AktuellNavigationDestination.detail(inputType: .id(id: postId))]))
        }
        
        // fotos
        if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "fotos" {
            return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.pfadijahre]))
        }
        
        // dokumente
        if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "downloads" {
            return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.dokumente]))
        }
        
        // lüüchtturm
        if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "luuchtturm" {
            return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.luuchtturm]))
        }
        
        // leitungsteam
        if pathComponentsCount == 3 && pathComponents[1] == "stufen" {
            if let lastPathComponent = pathComponents.last {
                if lastPathComponent.contains("biber") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Biberstufe")]))
                }
                else if lastPathComponent.contains("wolf") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Wolfsstufe")]))
                }
                else if lastPathComponent.contains("pfadi") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Pfadistufe")]))
                }
                else if lastPathComponent.contains("pio") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Piostufe")]))
                }
                else if lastPathComponent.contains("rover") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Roverstufe")]))
                }
                else if lastPathComponent.contains("abteilung") {
                    return (AppMainTab.mehr, NavigationPath([MehrNavigationDestination.leitungsteam(stufe: "Abteilungsleitung")]))
                }
            }
            else {
                return nil
            }
        }
        
        // oauth callback
        if url.isOauthCallback {
            return (AppMainTab.account, NavigationPath())
        }
        
        return nil
    }
    
}

extension URL {
    var isOauthCallback: Bool {
        let pathComponents = pathComponents
        let pathComponentsCount = pathComponents.count
        if pathComponentsCount == 4 && pathComponents[1] == "oauth" && pathComponents.last == "callback" {
            return true
        }
        return false
    }
}
