//
//  CloudFunctionEventPayload.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.03.2025.
//
import Foundation

struct CloudFunctionEventPayload {
    let summary: String
    let description: String
    let location: String
    let isAllDay: Bool
    let start: Date
    let end: Date
}

extension CloudFunctionEventPayload {
    
    func toCloudFunctionEventPayloadDto() throws -> CloudFunctionEventPayloadDto {
        
        let timeZoneForEvent = TimeZone(identifier: "Europe/Zurich")!
        
        return CloudFunctionEventPayloadDto(
            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : summary.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            start: GoogleCalendarEventStartEndDto(
                dateTime: isAllDay ? nil : try DateTimeUtil.shared.getIso8601DateString(date: start, timeZone: timeZoneForEvent),
                date: isAllDay ? DateTimeUtil.shared.formatDate(date: start, format: "yyyy-MM-dd", withRelativeDateFormatting: false, timeZone: timeZoneForEvent) : nil
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: isAllDay ? nil : try DateTimeUtil.shared.getIso8601DateString(date: end, timeZone: timeZoneForEvent),
                date: isAllDay ? DateTimeUtil.shared.formatDate(date: try DateTimeUtil.shared.newDate(byAdding: .day, value: -1, to: end), format: "yyyy-MM-dd", withRelativeDateFormatting: false, timeZone: timeZoneForEvent) : nil
            )
        )
    }
    
    func toGoogleCalendarEvent() throws -> GoogleCalendarEvent {
        
        let targetDisplayTimezone = TimeZone(identifier: "Europe/Zurich")!
        let now = Date()
        let nowString = DateTimeUtil.shared.formatDate(
            date: now,
            format: "d. MMMM, HH:mm 'Uhr'",
            withRelativeDateFormatting: true,
            timeZone: targetDisplayTimezone
        )
        
        return GoogleCalendarEvent(
            id: UUID().uuidString,
            title: summary,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            created: now,
            updated: now,
            createdString: nowString,
            updatedString: nowString,
            isAllDay: isAllDay,
            firstDayOfMonthOfStartDate: try DateTimeUtil.shared.getFirstDayOfMonthOfADate(date: start),
            startDate: start,
            endDate: end,
            startDayString: DateTimeUtil.shared.formatDate(
                date: start,
                format: "dd.",
                withRelativeDateFormatting: false,
                timeZone: targetDisplayTimezone
            ),
            startMonthString: DateTimeUtil.shared.formatDate(
                date: start,
                format: "MMM",
                withRelativeDateFormatting: false,
                timeZone: targetDisplayTimezone
            ),
            endDateString: DateTimeUtil.shared.getEventEndDateString(startDate: start, endDate: end, timeZone: targetDisplayTimezone),
            timeString: DateTimeUtil.shared.getEventTimeString(isAllDay: isAllDay, startDate: start, endDate: end, timeZone: targetDisplayTimezone),
            fullDateTimeString: DateTimeUtil.shared.getEventFullDateTimeString(isAllDay: isAllDay, startDate: start, endDate: end, timezone: targetDisplayTimezone)
        )
    }
}
