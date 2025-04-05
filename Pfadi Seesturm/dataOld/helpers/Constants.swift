//
//  Constants.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import CoreLocation

// normal (string) constants
struct Constants {
    
    static let SCHOPFLI_LOCATION = CLLocation(latitude: 47.530457, longitude: 9.362085)
    static let SCHOPFLIALARM_MAX_DISTANCE: Double = 100 // m
    
    static var OAUTH_CONFIG = OAuthApplicationConfig(
        issuer: URL(string: "https://db.scout.ch")!,
        clientID: "amedEopij2UUJChtHzUulytzcq7cmjOQkqZ9i_T6uMQ",
        redirectUri: URL(string: "https://seesturm.ch/oauth/app/callback")!,
        scope: [
            "email",
            "name",
            "with_roles",
            "openid"
        ]
    )
    static var OAUTH_TOKEN_ENDPOINT = URL(string: "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/oauth/token")!
    static var OAUTH_USER_INFO_ENDPOINT = "https://db.scout.ch/oauth/userinfo"
    static var HITOBITO_APP_GROUP_ID = 12399
    
    // Seesturm REST API endpoints
    static var SEESTURM_API_BASE_URL = "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/"
    
    // placeholder text
    static var PLACEHOLDER_TEXT = "Lorem ipsum odor amet, consectetuer adipiscing elit. Lobortis duis lacinia venenatis dapibus libero proin. Sit suscipit dictum curae bibendum aliquam. Ex diam magna lacinia fringilla id, risus quisque eros. Parturient hendrerit quisque torquent molestie sociosqu suscipit ex semper. Phasellus mus amet iaculis mollis cursus sit nisl. Nulla ac risus suspendisse magna accumsan maecenas. Maximus dictum ac ligula dolor maximus leo dapibus ac vestibulum. Dis adipiscing taciti ad facilisis, nostra massa. Semper ante sociosqu bibendum rhoncus suscipit nullam. Curabitur ante netus volutpat velit, finibus ante hendrerit."
    
    // Base url for google calendar
    static var GOOGLE_CALENDAR_BASE_URL = "https://seesturm.ch/wp-json/seesturmAppCustomEndpoints/v2/events/"
    
    // link to google form for app feedback
    static var FEEDBACK_FORM_URL = "https://docs.google.com/forms/d/e/1FAIpQLSfT0fEhmPpLxrY4sUjkuYwbchMENu1a5pPwpe5NQ2kCqkYL1A/viewform?usp=sf_link"
    
    // datenschutzerklärung
    static var DATENSCHUTZERKLAERUNG_URL = "https://seesturm.ch/datenschutz/"
    
    // max an min artificial delay for network calls
    static var MIN_ARTIFICIAL_DELAY: Double = 0.3
    static var MAX_ARTIFICIAL_DELAY: Double = 0.6
    
    // check if the app is run in debug mode
    static var IS_DEBUG: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
}
