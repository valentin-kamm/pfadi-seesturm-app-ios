//
//  TermineCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.11.2024.
//

import SwiftUI
import RichText

struct TermineCardView: View {
    
    let event: GoogleCalendarEvent
    var calendar: SeesturmCalendar
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            HStack(alignment: .center, spacing: 16) {
                CustomCardView(shadowColor: .clear, backgroundColor: Color(UIColor.systemGray5)) {
                    VStack(alignment: .center, spacing: 8) {
                        if let endDate = event.endDateString {
                            Text(event.startDayString + " " + event.startMonthString)
                                .lineLimit(1)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                            Text(endDate)
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                        else {
                            Text(event.startDayString)
                                .lineLimit(1)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                            Text(event.startMonthString)
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                    }
                    .frame(width: 100, height: 75)
                    .padding(8)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text(event.title)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Label {
                        Text(event.timeString)
                            .foregroundStyle(Color.secondary)
                            .font(.subheadline)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                    }
                    .labelStyle(.titleAndIcon)
                    if let location = event.location {
                        Label {
                            Text(location)
                                .foregroundStyle(Color.secondary)
                                .font(.subheadline)
                                .lineLimit(1)
                        } icon: {
                            Image(systemName: "location")
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                        }
                        .labelStyle(.titleAndIcon)
                    }
                }
                .layoutPriority(1)
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.secondary)
            }
            .padding()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview("Mehrtägiger Anlass") {
    TermineCardView(
        event: TermineCardViewPreviewExtension().multiDayEventData(),
        calendar: .termineLeitungsteam
    )
}
#Preview("Eintägiger Anlass") {
    TermineCardView(
        event: TermineCardViewPreviewExtension().oneDayEventData(),
        calendar: .termine
    )
}
#Preview("Ganztägiger, mehrtägiger Anlass") {
    TermineCardView(
        event: TermineCardViewPreviewExtension().allDayMultiDayEventData(),
        calendar: .termine
    )
}
#Preview("Ganztägiger, eintägiger Anlass") {
    TermineCardView(
        event: TermineCardViewPreviewExtension().allDayOneDayEventData(),
        calendar: .termine
    )
}

struct TermineCardViewPreviewExtension {
    func allDayOneDayEventData() -> GoogleCalendarEvent {
        return try! GoogleCalendarEventDto(
            id: "02i2p1qa6lealcck1mb1sguldk",
            summary: "Keine Aktivitäten für alle Stufen!",
            description: "Da sich das Leitungsteam an einem kantonalen Anlass weiterbildet, fallen die Aktivitäten an diesem Samstag aus.",
            location: "Pfadiheim Neukirch (Egnach), Amriswilerstrasse 31, 9315 Egnach, Schweiz",
            created: "2022-08-28T15:25:45.701Z",
            updated: "2022-08-28T15:25:45.726Z",
            start: GoogleCalendarEventStartEndDto(
                dateTime: nil,
                date: "2022-09-24"
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: nil,
                date: "2022-09-25"
            )
        ).toGoogleCalendarEvent()
    }
    func allDayMultiDayEventData() -> GoogleCalendarEvent {
        return try! GoogleCalendarEventDto(
            id: "3c4904s4q0dj4ldtc149kvq56m",
            summary: "Weihnachtsferien",
            description: "Keine Pfadi",
            location: nil,
            created: "2022-08-28T15:25:45.701Z",
            updated: "2022-08-28T15:25:45.726Z",
            start: GoogleCalendarEventStartEndDto(
                dateTime: nil,
                date: "2022-12-24"
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: nil,
                date: "2023-01-08"
            )
        ).toGoogleCalendarEvent()
    }
    func oneDayEventData() -> GoogleCalendarEvent {
        return try! GoogleCalendarEventDto(
            id: "17v15laf167s75oq47elh17a3t",
            summary: "Pfadi-Chlaus",
            description: "Ob uns wohl der Pfadi-Chlaus dieses Jahr wieder viele Nüssli und Schöggeli bringt? Die genauen Zeiten werden später kommuniziert.",
            location: "Geiserparkplatz",
            created: "2022-08-28T15:25:45.701Z",
            updated: "2022-08-27T15:19:45.726Z",
            start: GoogleCalendarEventStartEndDto(
                dateTime: "2022-12-10T13:00:00Z",
                date: nil
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: "2022-12-10T15:00:00Z",
                date: nil
            )
        ).toGoogleCalendarEvent()
    }
    func multiDayEventData() -> GoogleCalendarEvent {
        return try! GoogleCalendarEventDto(
            id: "429ri9n9l4ic0q9c00q5tj3hgf",
            summary: "Wolfsstufen-Weekend",
            description: "Die Wolfsstufe erlebt zusammen mit den Prinzen und dem Froschkönig ein spannendes Weekend. Sei auch du dabei und melde dich an!",
            location: nil,
            created: "2022-08-28T15:25:45.701Z",
            updated: "2022-08-28T15:25:45.726Z",
            start: GoogleCalendarEventStartEndDto(
                dateTime: "2022-10-01T08:00:00Z",
                date: nil
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: "2022-10-02T09:00:00Z",
                date: nil
            )
        ).toGoogleCalendarEvent()
    }
}
