//
//  Weather.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation
import WeatherKit

struct Weather: Codable, Hashable {
    var attributionURL: String
    var readTime: String
    var daily: DailyWeather
    var hourly: [HourlyWeather]
}
struct DailyWeather: Codable, Hashable {
    var forecastStart: Date
    var forecastEnd: Date
    var day: String
    var conditionCode: WeatherCondition?
    var description: String
    var temperatureMax: String
    var temperatureMin: String
    var precipitationAmount: String
    var precipitationChance: String
    var snowfallAmount: String
    var cloudCover: String
    var humidity: String
    var windDirection: String
    var windSpeed: String
    var sunrise: Date
    var sunriseString: String
    var sunset: Date
    var sunsetString: String
}
struct HourlyWeather: Codable, Identifiable, Hashable {
    var id: UUID
    var forecastStart: Date
    var cloudCover: Double
    var precipitationType: String
    var precipitationAmount: Double
    var snowfallAmount: Double
    var temperature: Double
    var windSpeed: Double
    var windGust: Double
}
