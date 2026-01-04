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
                date: isAllDay ? DateTimeUtil.shared.formatDate(
                    date: start,
                    format: "yyyy-MM-dd",
                    timeZone: timeZoneForEvent,
                    type: .absolute
                )
                : nil
            ),
            end: GoogleCalendarEventStartEndDto(
                dateTime: isAllDay ? nil : try DateTimeUtil.shared.getIso8601DateString(date: end, timeZone: timeZoneForEvent),
                date: isAllDay ? DateTimeUtil.shared.formatDate(
                    date: try DateTimeUtil.shared.newDate(byAdding: .day, value: 1, to: end),
                    format: "yyyy-MM-dd",
                    timeZone: timeZoneForEvent,
                    type: .absolute
                )
                : nil
            )
        )
    }
    
    func toGoogleCalendarEvent() throws -> GoogleCalendarEvent {
        
        let targetDisplayTimezone = TimeZone(identifier: "Europe/Zurich")!
        
        let now = Date()
        let nowString = DateTimeUtil.shared.formatDate(
            date: now,
            format: "d. MMMM, HH:mm 'Uhr'",
            timeZone: targetDisplayTimezone,
            type: .relative(withTime: true)
        )
        
        let startDate: Date
        if !isAllDay {
            startDate = start
        }
        else {
            startDate = Calendar.current.startOfDay(for: start)
        }
        let endDate: Date
        if !isAllDay {
            endDate = end
        }
        else {
            endDate = Calendar.current.startOfDay(for: end)
        }
        
        return GoogleCalendarEvent(
            id: UUID().uuidString,
            title: summary.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : location.trimmingCharacters(in: .whitespacesAndNewlines),
            created: now,
            modified: now,
            createdFormatted: nowString,
            modifiedFormatted: nowString,
            isAllDay: isAllDay,
            firstDayOfMonthOfStartDate: try DateTimeUtil.shared.getFirstDayOfMonth(of: start),
            start: startDate,
            end: endDate,
            startDateFormatted: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "dd. MMMM yyyy",
                timeZone: targetDisplayTimezone,
                type: .absolute
            ),
            startDayFormatted: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "dd.",
                timeZone: targetDisplayTimezone,
                type: .absolute
            ),
            startMonthFormatted: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "MMM",
                timeZone: targetDisplayTimezone,
                type: .absolute
            ),
            endDateFormatted: DateTimeUtil.shared.getEventEndDateString(startDate: startDate, endDate: endDate, timeZone: targetDisplayTimezone),
            timeFormatted: DateTimeUtil.shared.getEventTimeString(isAllDay: isAllDay, startDate: startDate, endDate: endDate, timeZone: targetDisplayTimezone),
            fullDateTimeFormatted: try DateTimeUtil.shared.getEventFullDateTimeString(isAllDay: isAllDay, startDate: startDate, endDate: endDate, timezone: targetDisplayTimezone)
        )
    }
}
