//
//  SeesturmUniversalLink.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import SwiftUI

enum SeesturmUniversalLink {
    
    case aktuell
    case aktuellPost(postId: Int)
    case oauthCallback
    case fotos
    case dokumente
    case lüüchtturm
    
    init?(url: URL) {
        
        if url.host(percentEncoded: true) != "seesturm.ch" {
            return nil
        }
        let pathComponents = url.pathComponents
        let pathComponentsCount = pathComponents.count
        
        if pathComponentsCount == 4 && pathComponents[1] == "oauth" && pathComponents.last == "callback" {
            self = .oauthCallback
        }
        else if pathComponentsCount == 2 && pathComponents.last == "aktuell" {
            self = .aktuell
        }
        else if pathComponentsCount == 3, url.pathComponents[1] == "aktuell", let postId = Int(url.lastPathComponent) {
            self = .aktuellPost(postId: postId)
        }
        else if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "fotos" {
            self = .fotos
        }
        else if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "downloads" {
            self = .dokumente
        }
        else if pathComponentsCount == 3 && pathComponents[1] == "medien" && pathComponents.last == "luuchtturm" {
            self = .lüüchtturm
        }
        else {
            return nil
        }
    }
    
    var navigationDestination: (AppMainTab, NavigationPath) {
        switch self {
        case .aktuell:
            return (.aktuell, NavigationPath())
        case .aktuellPost(let postId):
            return (.aktuell, NavigationPath([AktuellNavigationDestination.detail(inputType: .id(id: postId))]))
        case .oauthCallback:
            return (.account, NavigationPath())
        case .fotos:
            return (.mehr, NavigationPath([MehrNavigationDestination.pfadijahre(forceReload: true)]))
        case .dokumente:
            return (.mehr, NavigationPath([MehrNavigationDestination.dokumente]))
        case .lüüchtturm:
            return (.mehr, NavigationPath([MehrNavigationDestination.luuchtturm]))
        }
    }
}
