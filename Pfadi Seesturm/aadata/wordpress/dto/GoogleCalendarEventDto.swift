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
}
struct GoogleCalendarEventStartEndDto: Codable {
    var dateTime: String?
    var date: String?
}

extension GoogleCalendarEventDto {
        
    func toGoogleCalendarEvent(calendarTimeZone: TimeZone = TimeZone(identifier: "Europe/Zurich")!) throws -> GoogleCalendarEvent {
        
        let targetDisplayTimezone = TimeZone(identifier: "Europe/Zurich")!
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone, targetDisplayTimezone: targetDisplayTimezone)
        let endDate = try getEndDate(calendarTimeZone: calendarTimeZone, targetDisplayTimezone: targetDisplayTimezone)
        let createdDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: created)
        let updatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: created)
        
        return GoogleCalendarEvent(
            id: id,
            title: summary ?? "Unbenannter Anlass",
            description: description,
            location: location,
            created: createdDate,
            updated: updatedDate,
            createdString: DateTimeUtil.shared.formatDate(
                date: createdDate,
                format: "d. MMMM, HH:mm 'Uhr'",
                withRelativeDateFormatting: true,
                timeZone: targetDisplayTimezone
            ),
            updatedString: DateTimeUtil.shared.formatDate(
                date: updatedDate,
                format: "d. MMMM, HH:mm 'Uhr'",
                withRelativeDateFormatting: true,
                timeZone: targetDisplayTimezone
            ),
            isAllDay: isAllDay,
            firstDayOfMonthOfStartDate: try DateTimeUtil.shared.getFirstDayOfMonthOfADate(date: startDate),
            startDate: startDate,
            endDate: endDate,
            startDayString: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "dd.",
                withRelativeDateFormatting: false,
                timeZone: targetDisplayTimezone
            ),
            startMonthString: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "MMM",
                withRelativeDateFormatting: false,
                timeZone: targetDisplayTimezone
            ),
            endDateString: DateTimeUtil.shared.getEventEndDateString(
                startDate: startDate,
                endDate: endDate,
                timeZone: targetDisplayTimezone
            ),
            timeString: DateTimeUtil.shared.getEventTimeString(
                isAllDay: isAllDay,
                startDate: startDate,
                endDate: endDate,
                timeZone: targetDisplayTimezone
            ),
            fullDateTimeString: DateTimeUtil.shared.getEventFullDateTimeString(
                isAllDay: isAllDay,
                startDate: startDate,
                endDate: endDate,
                timezone: targetDisplayTimezone
            )
        )
    }
    
    var isAllDay: Bool {
        start.dateTime == nil
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
                    throw PfadiSeesturmAppError.dateDecodingError(message: "Ungültiges Enddatum")
                }
            }
            else {
                return endDate
            }
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Anlass ohne Enddatum vorhanden.")
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
            throw PfadiSeesturmAppError.dateDecodingError(message: "Anlass ohne Startdatum vorhanden.")
        }
    }
}
