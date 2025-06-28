//
//  HourlyWeatherDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.05.2025.
//
import Foundation

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

extension HourlyWeatherDto {
    func toHourlyWeather() throws -> HourlyWeather {
        return HourlyWeather(
            id: UUID(),
            forecastStart: try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: forecastStart),
            cloudCoverPercentage: 100 * cloudCover,
            precipitationType: precipitationType,
            precipitationAmount: precipitationAmount,
            snowfallAmount: snowfallAmount,
            temperature: temperature,
            windSpeed: windSpeed,
            windGust: windGust
        )
    }
}
