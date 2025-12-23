//
//  PhotoSliderViewItem.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 23.12.2025.
//
import Foundation

struct PhotoSliderViewItem: Identifiable {
    var id: UUID
    var url: URL?
    var aspectRatio: Double
    
    init(from wordpressPhoto: WordpressPhoto) {
        self.id = wordpressPhoto.id
        self.url = URL(string: wordpressPhoto.originalUrl)
        self.aspectRatio = Double(wordpressPhoto.width) / Double(wordpressPhoto.height)
    }
    
    init?(from user: FirebaseHitobitoUser) {
        if user.profilePictureUrl == nil {
            return nil
        }
        self.id = UUID()
        self.url = user.profilePictureUrl
        self.aspectRatio = 1
    }
}
