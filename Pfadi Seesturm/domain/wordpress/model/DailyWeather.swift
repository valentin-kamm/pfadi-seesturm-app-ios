//
//  DailyWeather.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//
import WeatherKit
import Foundation

struct DailyWeather: Codable, Hashable {
    var forecastStart: Date
    var forecastEnd: Date
    var dayFormatted: String
    var weatherCondition: WeatherCondition?
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
    var sunriseFormatted: String
    var sunset: Date
    var sunsetFormatted: String
    
    var description: String {
        weatherCondition?.description ?? "Unbekannt"
    }
}
