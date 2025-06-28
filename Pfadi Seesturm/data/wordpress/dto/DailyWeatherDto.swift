//
//  DailyWeatherDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.05.2025.
//
import Foundation
import WeatherKit

struct DailyWeatherDto: Codable {
    var forecastStart: String
    var forecastEnd: String
    var conditionCode: String
    var temperatureMax: Double
    var temperatureMin: Double
    var precipitationAmount: Double
    var precipitationChance: Double
    var snowfallAmount: Double
    var cloudCover: Double
    var humidity: Double
    var windDirection: Double
    var windSpeed: Double
    var sunrise: String
    var sunset: String
}

extension DailyWeatherDto {
    func toDailyWeather() throws -> DailyWeather {
        
        let forecastStartDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastStart)
        let forecastEndDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastEnd)
        let sunriseDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: sunrise)
        let sunsetDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: sunset)
        let weatherCondition = convertConditionCode()
        
        return DailyWeather(
            forecastStart: forecastStartDate,
            forecastEnd: forecastEndDate,
            dayFormatted: DateTimeUtil.shared.formatDate(
                date: forecastStartDate,
                format: "EEEE, d. MMMM",
                timeZone: .current,
                type: .relative(withTime: false)
            ),
            weatherCondition: weatherCondition,
            temperatureMax: "\(Int(round(temperatureMax)))°",
            temperatureMin: "\(Int(round(temperatureMin)))°",
            precipitationAmount: "\(Int(round(precipitationAmount))) mm",
            precipitationChance: "\(Int(round(100 * precipitationChance))) %",
            snowfallAmount: "\(Int(round(snowfallAmount))) mm",
            cloudCover: "\(Int(round(100 * cloudCover))) %",
            humidity: "\(Int(round(100 * humidity))) %",
            windDirection: convertWindDirection(),
            windSpeed: "\(Int(round(windSpeed))) km/h",
            sunrise: sunriseDate,
            sunriseFormatted: DateTimeUtil.shared.formatDate(
                date: sunriseDate,
                format: "HH:mm",
                timeZone: .current,
                type: .absolute
            ),
            sunset: sunsetDate,
            sunsetFormatted: DateTimeUtil.shared.formatDate(
                date: sunsetDate,
                format: "HH:mm",
                timeZone: .current,
                type: .absolute
            )
        )
    }
    private func convertWindDirection() -> String {
        let ranges: [Range<Double>] = [
            11.25..<33.75,
            33.75..<56.25,
            56.25..<78.75,
            78.75..<101.25,
            101.25..<123.75,
            123.75..<146.25,
            146.25..<168.75,
            168.75..<191.25,
            191.25..<213.75,
            213.75..<236.25,
            236.25..<258.75,
            258.75..<281.25,
            281.25..<303.75,
            303.75..<326.25,
            326.25..<348.75
        ]
        let directions: [String] = [
            "NNO",
            "NO",
            "ONO",
            "O",
            "OSO",
            "SO",
            "SSO",
            "S",
            "SSW",
            "SW",
            "WSW",
            "W",
            "WNW",
            "NW",
            "NNW",
        ]
        for (index, range) in ranges.enumerated() {
            if range.contains(windDirection) {
                return directions[index]
            }
        }
        return "N"
    }
    
    private func convertConditionCode() -> WeatherCondition? {
        let firstLetter = conditionCode.prefix(1).lowercased()
        let correctedCode = firstLetter + conditionCode.dropFirst(1)
        return WeatherCondition(rawValue: correctedCode)
    }
}
