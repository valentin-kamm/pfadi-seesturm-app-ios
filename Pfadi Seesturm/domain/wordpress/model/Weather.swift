//
//  Weather.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

struct Weather: Codable, Hashable {
    var attributionURL: String
    var readTimeFormatted: String
    var daily: DailyWeather
    var hourly: [HourlyWeather]
}
