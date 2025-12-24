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
        
        if Constants.IS_DEBUG {
            switch self {
            case .termine:
                return CalendarData(
                    calendarId: "c_801f9810a324034989384340ec73433d0c2497d4c081463d4423e1b1f710b9a4@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_801f9810a324034989384340ec73433d0c2497d4c081463d4423e1b1f710b9a4%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_801f9810a324034989384340ec73433d0c2497d4c081463d4423e1b1f710b9a4%40group.calendar.google.com/public/basic.ics")!
                )
            case .termineLeitungsteam:
                return CalendarData(
                    calendarId: "c_78e4c9946871d65432dd8d300313c01663605bcd3b856492ccd4fdb8234b9baa@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_78e4c9946871d65432dd8d300313c01663605bcd3b856492ccd4fdb8234b9baa%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_78e4c9946871d65432dd8d300313c01663605bcd3b856492ccd4fdb8234b9baa%40group.calendar.google.com/public/basic.ics")!
                )
            case .aktivitaetenBiberstufe:
                return CalendarData(
                    calendarId: "c_41a54fbf732083f444e205c55f604a9d47838f2e56de68bcf653d52f9204f01d@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_41a54fbf732083f444e205c55f604a9d47838f2e56de68bcf653d52f9204f01d%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_41a54fbf732083f444e205c55f604a9d47838f2e56de68bcf653d52f9204f01d%40group.calendar.google.com/public/basic.ics")!
                )
            case .aktivitaetenWolfsstufe:
                return CalendarData(
                    calendarId: "c_821e23aa03f41911eb2df99732e3de2e746c73c0503c77413d98d9d97cde9a60@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_821e23aa03f41911eb2df99732e3de2e746c73c0503c77413d98d9d97cde9a60%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_821e23aa03f41911eb2df99732e3de2e746c73c0503c77413d98d9d97cde9a60%40group.calendar.google.com/public/basic.ics")!
                )
            case .aktivitaetenPfadistufe:
                return CalendarData(
                    calendarId: "c_2292ba28015d2fba215886e8ce9c2fc6332d6eccd77b02cc1698efc9f0b3ac3e@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_2292ba28015d2fba215886e8ce9c2fc6332d6eccd77b02cc1698efc9f0b3ac3e%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_2292ba28015d2fba215886e8ce9c2fc6332d6eccd77b02cc1698efc9f0b3ac3e%40group.calendar.google.com/public/basic.ics")!
                )
            case .aktivitaetenPiostufe:
                return CalendarData(
                    calendarId: "c_2be94ae94b4fff65b112bcc02d3ce1c02d26bc6b3a1007530c651227f5f95e90@group.calendar.google.com",
                    subscriptionUrl: URL(string: "webcal://calendar.google.com/calendar/ical/c_2be94ae94b4fff65b112bcc02d3ce1c02d26bc6b3a1007530c651227f5f95e90%40group.calendar.google.com/public/basic.ics")!,
                    httpSubscriptionUrl: URL(string: "https://calendar.google.com/calendar/ical/c_2be94ae94b4fff65b112bcc02d3ce1c02d26bc6b3a1007530c651227f5f95e90%40group.calendar.google.com/public/basic.ics")!
                )
            }
        }
        else {
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
