//
//  WeatherRepositoryImpl.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

class WeatherRepositoryImpl: WeatherRepository {
    
    private let api: WordpressApi
    init(api: WordpressApi) {
        self.api = api
    }
    
    func getWeather() async throws -> WeatherDto {
        return try await api.getWeather()
    }
}
