//
//  DateTimeUtil.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI
import FirebaseFirestore

class DateTimeUtil {
    
    static let shared = DateTimeUtil()
    
    func convertFirestoreTimestampToDate(timestamp: Timestamp?) throws -> Date {
        if let ts = timestamp {
            return ts.dateValue()
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datum nicht vorhanden.")
        }
    }
    
    // function that takes date and formats it as iso8601 date
    func getIso8601DateString(date: Date, timeZone: TimeZone?) throws -> String {
        if let tz = timeZone {
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = tz
            return formatter.string(from: date)
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Das Datum ist falsch.")
        }
    }
    
    // function to get the start of the month of the provided date
    func getFirstDayOfMonthOfADate(date: Date) throws -> Date {
        let calendar = Calendar.current
        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
            return startOfMonth
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Fehler bei der Datumsverarbeitung.")
        }
    }
    
    // function to parse a floating date string in the format yyyy-MM-dd
    func parseFloatingDateString(floatingDateString: String, floatingDateTimeZone: TimeZone) throws -> Date {
        let df = DateFormatter()
        df.timeZone = floatingDateTimeZone
        df.dateFormat = "yyyy-MM-dd"
        if let date = df.date(from: floatingDateString) {
            return date
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Datumsformat ungültig.")
        }
    }
    
    // functions to parse a ISO 8601 datetime string
    func parseISO8601DateWithTimeZone(iso8601DateString: String) throws -> Date {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        if let date = df.date(from: iso8601DateString) {
            return date
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Datumsformat ungültig.")
        }
    }
    func parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: String) throws -> Date {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone, .withFractionalSeconds]
        if let date = df.date(from: iso8601DateString) {
            return date
        }
        else {
            throw PfadiSeesturmError.dateError(message: "Datumsformat ungültig.")
        }
    }
    
    // function to format a date range
    func formatDateRange(startDate: Date, endDate: Date, timeZone: TimeZone, withTime: Bool) -> String {
        let formatter = DateIntervalFormatter()
        formatter.locale = Locale(identifier: "de_CH")
        formatter.timeZone = timeZone
        formatter.dateStyle = .full
        formatter.timeStyle = withTime ? .short : .none
        return formatter.string(from: startDate, to: endDate)
    }
    
    // function to format a date into the desired string format
    // if a relative date format is desired and available, return it instead
    func formatDate(date: Date, format: String, withRelativeDateFormatting: Bool, includeTimeInRelativeFormatting: Bool? = nil, timeZone: TimeZone) -> String {
        
        // custom date formatter
        let customDf = DateFormatter()
        customDf.timeZone = timeZone
        customDf.locale = Locale(identifier: "de_CH")
        customDf.dateFormat = format
        
        // relative date formatter
        let relDf = DateFormatter()
        relDf.timeZone = timeZone
        relDf.locale = Locale(identifier: "de_CH")
        relDf.doesRelativeDateFormatting = true
        relDf.dateStyle = .long
        relDf.timeStyle = (includeTimeInRelativeFormatting ?? true ? .short : .none)
        
        // non-relative formatter with same style
        let nonRelDf = DateFormatter()
        nonRelDf.timeZone = timeZone
        nonRelDf.locale = Locale(identifier: "de_CH")
        nonRelDf.dateStyle = .long
        nonRelDf.timeStyle = (includeTimeInRelativeFormatting ?? true ? .short : .none)
        
        // get result from both formatters
        let rel = relDf.string(from: date)
        let nonRel = nonRelDf.string(from: date)
        
        // if no relative date formatting is desired
        if !withRelativeDateFormatting {
            return customDf.string(from: date)
        }
        // if the results are the same, it's not a relative date -> use custom date formatter
        else if rel == nonRel {
            return customDf.string(from: date)
        }
        // else, return relative date
        else {
            return rel + (includeTimeInRelativeFormatting ?? true ? " Uhr" : "")
        }
        
    }
    
    // get date of next saturday at desired time
    func nextSaturday(at hour: Int) -> Date {
        let calendar = Calendar.current
        let now = Date()
        guard let nextSaturday = calendar.nextDate(after: now, matching: DateComponents(weekday: 7), matchingPolicy: .nextTime) else {
            return now
        }
        var components = calendar.dateComponents([.year, .month, .day], from: nextSaturday)
        components.hour = hour
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? Date()
    }
    
    func newDate(byAdding: Calendar.Component, value: Int, to date: Date) throws -> Date {
        if let newDate = Calendar.current.date(byAdding: byAdding, value: value, to: date) {
            return newDate
        }
        throw PfadiSeesturmError.dateError(message: "Neues Datum ungültig. Die gewünschten Komponenten konnten nicht addiert/subtrahiert werden.")
    }
    
    // helper functions for google calendar events
    func isEventSingleDay(startDate: Date, endDate: Date) -> Bool {
        let calendar = Calendar.current
        let componentsStart = calendar.dateComponents([.year, .month, .day], from: startDate)
        let componentsEnd = calendar.dateComponents([.year, .month, .day], from: endDate)
        return componentsStart.year == componentsEnd.year &&
            componentsStart.month == componentsEnd.month &&
            componentsStart.day == componentsEnd.day
    }
    func getEventTimeString(isAllDay: Bool, startDate: Date, endDate: Date, timeZone: TimeZone) -> String {
        if (isAllDay) {
            return "Ganztägig"
        }
        else {
            let startTimeString = DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "HH:mm",
                withRelativeDateFormatting: false,
                timeZone: timeZone
            )
            let endTimeString = DateTimeUtil.shared.formatDate(
                date: endDate,
                format: "HH:mm",
                withRelativeDateFormatting: false,
                timeZone: timeZone
            )
            return "\(startTimeString) bis \(endTimeString) Uhr"
        }
    }
    func getEventFullDateTimeString(isAllDay: Bool, startDate: Date, endDate: Date, timezone: TimeZone) -> String {
        let isSingleDay = self.isEventSingleDay(startDate: startDate, endDate: endDate)
        if isSingleDay && isAllDay {
            let dateRangeString = DateTimeUtil.shared.formatDateRange(
                startDate: startDate,
                endDate: endDate,
                timeZone: timezone,
                withTime: false
            )
            return "\(dateRangeString), ganztägig"
        }
        else {
            return DateTimeUtil.shared.formatDateRange(
                startDate: startDate,
                endDate: endDate,
                timeZone: timezone,
                withTime: true
            )
        }
    }
    func getEventEndDateString(startDate: Date, endDate: Date, timeZone: TimeZone) -> String? {
        let isSingleDay = self.isEventSingleDay(startDate: startDate, endDate: endDate)
        if isSingleDay {
            return nil
        }
        else {
            return DateTimeUtil.shared.formatDate(date: endDate, format: "dd. MMM", withRelativeDateFormatting: false, timeZone: timeZone)
        }
    }
}
