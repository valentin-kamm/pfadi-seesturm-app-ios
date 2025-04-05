//
//  CustomColors.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 15.10.2024.
//

import SwiftUI

extension Color {
    
    // Seesturm colors
    static let SEESTURM_GREEN = Color(red: 42/255, green: 100/255, blue: 56/255)
    static let SEESTURM_RED = Color(red: 202/255, green: 43/255, blue: 54/255)
    static var SEESTURM_YELLOW = Color(red: 248/255, green: 213/255, blue: 72/255)
    static var SEESTURM_BLUE = Color(red: 33/255, green: 84/255, blue: 155/255)
    
    // custom color for background of entire views
    static let customBackground = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .black : .systemGroupedBackground
        }
    )
    
    // Color for custom card view background
    static let customCardViewBackground = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
        }
    )
    
    // Color for loading placeholders of skeleton views
    static let skeletonPlaceholderColor = Color(
        UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.placeholderText//((red: 64/255, green: 64/255, blue: 64/255, alpha: 1)
            }
            else {
                return UIColor.placeholderText//(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
            }
        }
    )
    
    // Color for card view shadows
    static let seesturmGreenCardViewShadowColor = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor.clear : UIColor(Color.SEESTURM_GREEN)
        }
    )
    
    // Color for wolfsstufe
    static let wolfsstufeColor = Color(
        UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(Color.SEESTURM_YELLOW) : UIColor.label
        }
    )
    
    static let seesturmGray = Color(UIColor.systemGray5)
    
}
