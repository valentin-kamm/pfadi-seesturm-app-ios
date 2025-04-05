//
//  WeatherService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//

class WeatherService: WordpressService {
    
    let repository: WeatherRepository
    init(repository: WeatherRepository) {
        self.repository = repository
    }
    
    func getWeather() async -> SeesturmResult<Weather, NetworkError> {
        let result = await fetchFromWordpress(
            fetchAction: { try await self.repository.getWeather() },
            transform: { try $0.toWeather() }
        )
        switch result {
        case .error(let e):
            return .error(e)
        case .success(let weather):
            if weather.hourly.isEmpty {
                return .error(NetworkError.invalidData)
            }
            else {
                return .success(weather)
            }
        }
    }
    
}
