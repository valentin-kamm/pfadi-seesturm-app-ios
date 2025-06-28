//
//  AnlassCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.11.2024.
//

import SwiftUI
import RichText

struct AnlassCardView: View {
    
    private let event: GoogleCalendarEvent
    private let calendar: SeesturmCalendar
    
    init(
        event: GoogleCalendarEvent,
        calendar: SeesturmCalendar
    ) {
        self.event = event
        self.calendar = calendar
    }
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            HStack(alignment: .center, spacing: 16) {
                CustomCardView(shadowColor: .clear, backgroundColor: .seesturmGray) {
                    VStack(alignment: .center, spacing: 8) {
                        if let endDate = event.endDateFormatted {
                            Text("\(event.startDayFormatted) \(event.startMonthFormatted)")
                                .lineLimit(1)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                            Text("bis \(endDate)")
                                .lineLimit(1)
                                .font(.subheadline)
                        }
                        else {
                            Text(event.startDayFormatted)
                                .lineLimit(1)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(calendar.isLeitungsteam ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
                            Text(event.startMonthFormatted)
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
                        Text(event.timeFormatted)
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

#Preview {
    VStack(alignment: .center, spacing: 0) {
        AnlassCardView(
            event: DummyData.multiDayEvent,
            calendar: .termine
        )
        AnlassCardView(
            event: DummyData.oneDayEvent,
            calendar: .termine
        )
        AnlassCardView(
            event: DummyData.allDayMultiDayEvent,
            calendar: .termineLeitungsteam
        )
        AnlassCardView(
            event: DummyData.allDayOneDayEvent,
            calendar: .termineLeitungsteam
        )
    }
    .frame(maxWidth: .infinity)
}
