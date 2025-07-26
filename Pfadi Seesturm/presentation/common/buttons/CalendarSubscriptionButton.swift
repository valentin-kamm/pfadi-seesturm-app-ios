//
//  CalendarSubscriptionButton.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 21.07.2025.
//

import SwiftUI

struct CalendarSubscriptionButton: View {
    
    @State private var isPresented: Bool = false
    
    private let calendar: SeesturmCalendar
    
    init(
        calendar: SeesturmCalendar
    ) {
        self.calendar = calendar
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "calendar.badge.plus")
        }
        .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
        .confirmationDialog(
            "Wie möchtest du den Kalender abonnieren?",
            isPresented: $isPresented,
            titleVisibility: .visible
        ) {
            Button("Abbrechen", role: .cancel) {
                // do nothing
            }
            // apple calendar
            if UIApplication.shared.canOpenURL(calendar.data.subscriptionUrl) {
                Button("Apple Kalender", role: .none) {
                    UIApplication.shared.open(calendar.data.subscriptionUrl)
                }
            }
            // google calendar
            if let googleUrl = URL(string: "https://calendar.google.com/calendar/u/0/r?cid=\(calendar.data.calendarId)"), UIApplication.shared.canOpenURL(googleUrl) {
                Button("Google Kalender", role: .none) {
                    UIApplication.shared.open(googleUrl)
                }
            }
            // copy to clipboard
            Button("URL kopieren") {
                UIPasteboard.general.string = calendar.data.httpSubscriptionUrl.absoluteString
            }
        }
    }
}

#Preview {
    CalendarSubscriptionButton(calendar: .termine)
    CalendarSubscriptionButton(calendar: .termineLeitungsteam)
}
