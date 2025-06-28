//
//  HourlyWeather.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.05.2025.
//
import Foundation

struct HourlyWeather: Codable, Identifiable, Hashable {
    var id: UUID
    var forecastStart: Date
    var cloudCoverPercentage: Double
    var precipitationType: String
    var precipitationAmount: Double
    var snowfallAmount: Double
    var temperature: Double
    var windSpeed: Double
    var windGust: Double
}
