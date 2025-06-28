//
//  WeatherIcon.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 09.06.2025.
//
import WeatherKit
import SwiftUI

extension WeatherCondition? {
    
    func getIcon(_ colorScheme: ColorScheme) -> Image {
        switch self {
        case .blizzard:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .blowingDust:
            return Image("blowingDust")
        case .blowingSnow:
            return Image("blizzard" + (colorScheme == .dark ? "-dark" : ""))
        case .breezy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .clear:
            return Image("clear")
        case .cloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .drizzle:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .flurries:
            return Image("flurries" + (colorScheme == .dark ? "-dark" : ""))
        case .foggy:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingDrizzle:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .freezingRain:
            return Image("freezingDrizzle" + (colorScheme == .dark ? "-dark" : ""))
        case .frigid:
            return Image("frigid" + (colorScheme == .dark ? "-dark" : ""))
        case .hail:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .haze:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .heavyRain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .heavySnow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .hot:
            return Image("hot")
        case .hurricane:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .isolatedThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyClear:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .mostlyCloudy:
            return Image("cloudy" + (colorScheme == .dark ? "-dark" : ""))
        case .partlyCloudy:
            return Image("mostlyClear" + (colorScheme == .dark ? "-dark" : ""))
        case .rain:
            return Image("heavyRain" + (colorScheme == .dark ? "-dark" : ""))
        case .scatteredThunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sleet:
            return Image("hail" + (colorScheme == .dark ? "-dark" : ""))
        case .smoky:
            return Image("foggy" + (colorScheme == .dark ? "-dark" : ""))
        case .snow:
            return Image("snow" + (colorScheme == .dark ? "-dark" : ""))
        case .strongStorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .sunFlurries:
            return Image("sunFlurries" + (colorScheme == .dark ? "-dark" : ""))
        case .sunShowers:
            return Image("sunShowers" + (colorScheme == .dark ? "-dark" : ""))
        case .thunderstorms:
            return Image("thunderstorms" + (colorScheme == .dark ? "-dark" : ""))
        case .tropicalStorm:
            return Image("hurricane" + (colorScheme == .dark ? "-dark" : ""))
        case .windy:
            return Image("windy" + (colorScheme == .dark ? "-dark" : ""))
        case .wintryMix:
            return Image("wintryMix" + (colorScheme == .dark ? "-dark" : ""))
        default:
            return Image(systemName: "questionmark.square.dashed")
        }
    }
}
