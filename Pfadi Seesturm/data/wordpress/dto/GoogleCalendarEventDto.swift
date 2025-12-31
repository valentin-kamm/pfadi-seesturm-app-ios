//
//  GoogleCalendarEventDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

struct GoogleCalendarEventDto: Identifiable, Codable {
    let id: String
    let summary: String?
    let description: String?
    let location: String?
    let created: String
    let updated: String
    let start: GoogleCalendarEventStartEndDto
    let end: GoogleCalendarEventStartEndDto
    
    var isAllDay: Bool {
        start.dateTime == nil
    }
}

extension GoogleCalendarEventDto {
        
    func toGoogleCalendarEvent(calendarTimeZone: TimeZone = TimeZone(identifier: "Europe/Zurich")!) throws -> GoogleCalendarEvent {
        
        let targetDisplayTimezone = TimeZone(identifier: "Europe/Zurich")!
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone, targetDisplayTimezone: targetDisplayTimezone)
        let endDate = try getEndDate(calendarTimeZone: calendarTimeZone, targetDisplayTimezone: targetDisplayTimezone)
        let createdDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: created)
        let modifiedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: updated)
        
        return GoogleCalendarEvent(
            id: id,
            title: summary ?? "Unbenannter Anlass",
            description: description,
            location: location,
            created: createdDate,
            modified: modifiedDate,
            createdFormatted: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "dd. MMM, HH:mm 'Uhr'",
                timeZone: targetDisplayTimezone,
                type: .relative(withTime: true)
            ),
            modifiedFormatted: DateTimeUtil.shared.formatDate(
                date: modifiedDate,
                format: "dd. MMM, HH:mm 'Uhr'",
                timeZone: targetDisplayTimezone,
                type: .relative(withTime: true)
            ),
            isAllDay: isAllDay,
            firstDayOfMonthOfStartDate: try DateTimeUtil.shared.getFirstDayOfMonth(of: startDate),
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
            endDateFormatted: DateTimeUtil.shared.getEventEndDateString(
                startDate: startDate,
                endDate: endDate,
                timeZone: targetDisplayTimezone
            ),
            timeFormatted: DateTimeUtil.shared.getEventTimeString(
                isAllDay: isAllDay,
                startDate: startDate,
                endDate: endDate,
                timeZone: targetDisplayTimezone
            ),
            fullDateTimeFormatted: DateTimeUtil.shared.getEventFullDateTimeString(
                isAllDay: isAllDay,
                startDate: startDate,
                endDate: endDate,
                timezone: targetDisplayTimezone
            )
        )
    }
    
    private func getEndDate(calendarTimeZone: TimeZone, targetDisplayTimezone: TimeZone) throws -> Date {
        if let endDateTimeString = end.dateTime {
            return try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: endDateTimeString)
        }
        else if let endDateString = end.date {
            let endDate = try DateTimeUtil.shared.parseFloatingDateString(floatingDateString: endDateString, floatingDateTimeZone: calendarTimeZone)
            if isAllDay {
                if let correctedEndDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate) {
                    return correctedEndDate
                }
                else {
                    throw PfadiSeesturmError.dateError(message: "Ungültiges Enddatum")
                }
            }
            else {
                return endDate
            }
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Anlass ohne Enddatum vorhanden.")
        }
    }
    
    private func getStartDate(calendarTimeZone: TimeZone, targetDisplayTimezone: TimeZone) throws -> Date {
        if let startDateTimeString = start.dateTime {
            return try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: startDateTimeString)
        }
        else if let startDateString = start.date {
            return try DateTimeUtil.shared.parseFloatingDateString(floatingDateString: startDateString, floatingDateTimeZone: calendarTimeZone)
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Anlass ohne Startdatum vorhanden.")
        }
    }
}
