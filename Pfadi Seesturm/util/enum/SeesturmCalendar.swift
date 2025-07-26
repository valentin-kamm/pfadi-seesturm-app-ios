//
//  SeesturmCalendar.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.06.2025.
//
import Foundation

enum SeesturmCalendar {
    
    case termine
    case termineLeitungsteam
    case aktivitaetenBiberstufe
    case aktivitaetenWolfsstufe
    case aktivitaetenPfadistufe
    case aktivitaetenPiostufe
    
    var data: CalendarData {
        switch self {
        case .termine:
            return CalendarData(
                calendarId: "app@seesturm.ch",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/app%40seesturm.ch/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/app%40seesturm.ch/public/basic.ics")!
            )
        case .termineLeitungsteam:
            return CalendarData(
                calendarId: "5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1%40group.calendar.google.com/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/5975051a11bea77feba9a0990756ae350a8ddc6ec132f309c0a06311b8e45ae1%40group.calendar.google.com/public/basic.ics")!,
            )
        case .aktivitaetenBiberstufe:
            return CalendarData(
                calendarId: "c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a%40group.calendar.google.com/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_7520d8626a32cf6eb24bff379717bb5c8ea446bae7168377af224fc502f0c42a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenWolfsstufe:
            return CalendarData(
                calendarId: "c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a%40group.calendar.google.com/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_e0edfd55e958543f4a4a370fdadcb5cec167e6df847fe362af9c0feb04069a0a%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPfadistufe:
            return CalendarData(
                calendarId: "c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e%40group.calendar.google.com/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_753fcf01c8730c92dfc6be4fac8c4aa894165cf451a993413303eaf016b1647e%40group.calendar.google.com/public/basic.ics")!
            )
        case .aktivitaetenPiostufe:
            return CalendarData(
                calendarId: "c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25@group.calendar.google.com",
                subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25%40group.calendar.google.com/public/basic.ics")!,
                httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_be80dc194bbf418bea3a613472f9811df8887e07332a363d6d1ed66056f87f25%40group.calendar.google.com/public/basic.ics")!
            )
        }
    }
    
    var isLeitungsteam: Bool {
        switch self {
        case .termineLeitungsteam:
            return true
        default:
            return false
        }
    }
}

struct CalendarData {
    let calendarId: String
    let subscriptionUrl: URL
    let httpSubscriptionUrl: URL
}
