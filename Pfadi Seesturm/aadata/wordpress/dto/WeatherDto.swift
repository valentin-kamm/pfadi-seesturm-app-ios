//
//  WeatherDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation
import WeatherKit

struct WeatherDto: Codable {
    var attributionURL: String
    var readTime: String
    var daily: DailyWeatherDto
    var hourly: [HourlyWeatherDto]
}
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
struct HourlyWeatherDto: Codable {
    var forecastStart: String
    var cloudCover: Double
    var precipitationType: String
    var precipitationAmount: Double
    var snowfallAmount: Double
    var temperature: Double
    var windSpeed: Double
    var windGust: Double
}

extension WeatherDto {
    func toWeather() throws -> Weather {
        return Weather(
            attributionURL: attributionURL,
            readTime: DateTimeUtil.shared.formatDate(
                date: try DateTimeUtil.shared.parseISO8601DateWithTimeZone(
                    iso8601DateString: readTime
                ),
                format: "dd.MM.yyyy, HH:dd",
                withRelativeDateFormatting: true,
                timeZone: .current
            ),
            daily: try daily.toDailyWeather(),
            hourly: try hourly.map { try $0.toHourlyWeather() }
        )
    }
}
extension DailyWeatherDto {
    func toDailyWeather() throws -> DailyWeather {
        let startDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastStart)
        let sunriseDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: sunrise)
        let sunsetDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: sunset)
        return DailyWeather(
            forecastStart: startDate,
            forecastEnd: try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastEnd),
            day: DateTimeUtil.shared.formatDate(
                date: startDate,
                format: "EEEE, d. MMMM",
                withRelativeDateFormatting: true,
                includeTimeInRelativeFormatting: false,
                timeZone: .current
            ),
            conditionCode: convertConditionCode(),
            description: getGermanWeatherDescription(),
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
            sunriseString: DateTimeUtil.shared.formatDate(
                date: sunriseDate,
                format: "HH:mm",
                withRelativeDateFormatting: false,
                timeZone: .current
            ),
            sunset: sunsetDate,
            sunsetString: DateTimeUtil.shared.formatDate(
                date: sunsetDate,
                format: "HH:mm",
                withRelativeDateFormatting: false,
                timeZone: .current
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
    private func getGermanWeatherDescription() -> String {
        if let condition = convertConditionCode() {
            return condition.description
        }
        else {
            return "Unbekannt"
        }
    }
}
extension HourlyWeatherDto {
    func toHourlyWeather() throws -> HourlyWeather {
        return HourlyWeather(
            id: UUID(),
            forecastStart: try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastStart),
            cloudCover: 100 * cloudCover,
            precipitationType: precipitationType,
            precipitationAmount: precipitationAmount,
            snowfallAmount: snowfallAmount,
            temperature: temperature,
            windSpeed: windSpeed,
            windGust: windGust
        )
    }
}
