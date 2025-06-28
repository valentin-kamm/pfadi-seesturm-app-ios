//
//  WeatherDto.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

struct WeatherDto: Codable {
    var attributionURL: String
    var readTime: String
    var daily: DailyWeatherDto
    var hourly: [HourlyWeatherDto]
}

extension WeatherDto {
    func toWeather() throws -> Weather {
        
        let readDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: readTime)
        
        return Weather(
            attributionURL: attributionURL,
            readTimeFormatted: DateTimeUtil.shared.formatDate(
                date: readDate,
                format: "dd.MM.yyyy, HH:dd 'Uhr'",
                timeZone: .current,
                type: .relative(withTime: true)
            ),
            daily: try daily.toDailyWeather(),
            hourly: try hourly.map { try $0.toHourlyWeather() }
        )
    }
}

