//
//  WeatherRepository.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

protocol WeatherRepository {
    func getWeather() async throws -> WeatherDto
}
